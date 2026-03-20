import Foundation

public protocol UserLibraryClient: Sendable {
    func itemsLatest(request: ItemsLatestRequest) async throws -> [Item]
}

public actor DefaultUserLibraryClient: UserLibraryClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let settings: JellyfinApiClientSettings
    
    public init(session: URLSession, decoder: JSONDecoder, settings: JellyfinApiClientSettings) {
        self.session = session
        self.decoder = decoder
        self.settings = settings
    }
    
    public func itemsLatest(request: ItemsLatestRequest) async throws -> [Item] {
        let url = settings.serverAddress.appending(path: "Items/Latest")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "userId", value: request.userId),
            URLQueryItem(name: "limit", value: String(request.limit))
        ]
        if let parentId = request.parentId {
            components.queryItems?.append(URLQueryItem(name: "parentId", value: parentId))
        }

        var req = URLRequest(url: components.url!)
        req.setValue("MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"", forHTTPHeaderField: "X-Emby-Authorization")
        req.setValue("MediaBrowser Token=\"\(settings.accessToken)\"", forHTTPHeaderField: "Authorization")
        req.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: req)
        
        let x = String(data: data, encoding: .utf8)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
        
        do {
            return try decoder.decode([Item].self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
