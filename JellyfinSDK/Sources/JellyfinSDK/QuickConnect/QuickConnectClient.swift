import Foundation

public protocol QuickConnectClient: Sendable {
    func initiate() async throws -> QuickConnectInitiateResponse
    func connect(request: QuickConnectConnectRequest) async throws -> QuickConnectConnectResponse
}

public actor DefaultQuickConnectClient: QuickConnectClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let settings: JellyfinApiClientSettings
    
    init(session: URLSession, decoder: JSONDecoder, settings: JellyfinApiClientSettings) {
        self.session = session
        self.decoder = decoder
        self.settings = settings
    }
    
    public func initiate() async throws -> QuickConnectInitiateResponse {
        let url = settings.serverAddress.appending(path: "QuickConnect/Initiate")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"", forHTTPHeaderField: "X-Emby-Authorization")
        
        let (data, response) = try await session.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
        
        do {
            return try decoder.decode(QuickConnectInitiateResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    public func connect(request: QuickConnectConnectRequest) async throws -> QuickConnectConnectResponse {
        let url = settings.serverAddress.appending(path: "QuickConnect/Connect")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "secret", value: request.secret)]
        
        var req = URLRequest(url: components.url!)
        req.httpMethod = "GET"
        req.setValue("MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"", forHTTPHeaderField: "X-Emby-Authorization")
        
        let (data, response) = try await session.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
        
        do {
            return try decoder.decode(QuickConnectConnectResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
