import Foundation

public protocol SystemClient: Sendable {
    func infoPublic() async throws -> InfoPublicResponse
}

public actor DefaultSystemClient: SystemClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let settings: JellyfinApiClientSettings
    
    public init(session: URLSession, decoder: JSONDecoder, settings: JellyfinApiClientSettings) {
        self.session = session
        self.decoder = decoder
        self.settings = settings
    }

    public func infoPublic() async throws -> InfoPublicResponse {
        let url = settings.serverAddress.appending(path: "System/Info/Public")
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
            return try decoder.decode(InfoPublicResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
