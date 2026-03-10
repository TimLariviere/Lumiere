import Foundation

public protocol JellyfinClientProtocol: Sendable {
    func getServerInfo(url: URL) async throws -> ServerInfoResponse
    func authenticateByName(baseURL: URL, token: String, request: UsersAuthenticateByNameRequest) async throws -> UsersAuthenticateByNameResponse
}

public struct ServerInfoResponse: Sendable, Decodable {
    public let id: String
    public let serverName: String
    public let version: String
    public let startupWizardCompleted: Bool
    
    public init(id: String, serverName: String, version: String, startupWizardCompleted: Bool) {
        self.id = id
        self.serverName = serverName
        self.version = version
        self.startupWizardCompleted = startupWizardCompleted
    }
}

public struct UsersAuthenticateByNameRequest: Sendable, Encodable {
    let username: String
    let pw: String
    
    public init(username: String, pw: String) {
        self.username = username
        self.pw = pw
    }
}

public struct UsersAuthenticateByNameResponse: Sendable, Decodable {
    public let user: UsersAuthenticateByNameResponse_User
    
    public init(user: UsersAuthenticateByNameResponse_User) {
        self.user = user
    }
}

public struct UsersAuthenticateByNameResponse_User: Sendable, Decodable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

public enum APIError: Error, LocalizedError {
    case invalidURL
    case httpError(statusCode: Int, data: Data)
    case decodingError(Error)
    
    public var errorDescription: String? {
        switch self {
            case .invalidURL: return "Invalid URL"
            case .httpError(let code, _): return "HTTP error: \(code)"
            case .decodingError(let e): return "Decoding failed: \(e.localizedDescription)"
        }
    }
}

public actor JellyfinClient: JellyfinClientProtocol {
    public static let shared = JellyfinClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Accept": "application/json"]
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder.pascalCaseDecoder()
    }

    public func getServerInfo(url: URL) async throws -> ServerInfoResponse {
        let url = url.appending(path: "System/Info/Public")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
        
        do {
            return try decoder.decode(ServerInfoResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    public func authenticateByName(baseURL: URL, token: String, request: UsersAuthenticateByNameRequest) async throws -> UsersAuthenticateByNameResponse {
        let url = baseURL.appending(path: "Users/AuthenticateByName")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"", forHTTPHeaderField: "X-Emby-Authorization")
        req.setValue("MediaBrowser Token=\"\(token)\"", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await session.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
        
        do {
            return try decoder.decode(UsersAuthenticateByNameResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
