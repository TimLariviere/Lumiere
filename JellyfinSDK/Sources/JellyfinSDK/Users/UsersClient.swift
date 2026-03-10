import Foundation

public protocol UsersClient: Sendable {
    func authenticateByName(request: UsersAuthenticateByNameRequest) async throws -> UsersAuthenticateByNameResponse
    func authenticateWithQuickConnect(request: UsersAuthenticateWithQuickConnectRequest) async throws -> UsersAuthenticateWithQuickConnectResponse
    func me() async throws -> UsersMeResponse
}

public actor DefaultUsersClient: UsersClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let settings: JellyfinApiClientSettings
    
    init(session: URLSession, decoder: JSONDecoder, settings: JellyfinApiClientSettings) {
        self.session = session
        self.decoder = decoder
        self.settings = settings
    }
    
    public func authenticateByName(request: UsersAuthenticateByNameRequest) async throws -> UsersAuthenticateByNameResponse {
        let url = settings.serverAddress.appending(path: "Users/AuthenticateByName")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"", forHTTPHeaderField: "X-Emby-Authorization")
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
    
    public func authenticateWithQuickConnect(request: UsersAuthenticateWithQuickConnectRequest) async throws -> UsersAuthenticateWithQuickConnectResponse {
        let url = settings.serverAddress.appending(path: "Users/AuthenticateWithQuickConnect")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"", forHTTPHeaderField: "X-Emby-Authorization")
        req.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await session.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
        
        do {
            return try decoder.decode(UsersAuthenticateWithQuickConnectResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    public func me() async throws -> UsersMeResponse {
        let url = settings.serverAddress.appending(path: "Users/Me")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"", forHTTPHeaderField: "X-Emby-Authorization")
        req.setValue("MediaBrowser Token=\"\(settings.accessToken)\"", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
        
        do {
            return try decoder.decode(UsersMeResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
