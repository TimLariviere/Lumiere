import Foundation

public protocol TvShowsClient: Sendable {
    func seasons(request: SeasonsRequest) async throws -> SeasonsResponse
    func episodes(request: EpisodesRequest) async throws -> EpisodesResponse
}

public actor DefaultTvShowsClient: TvShowsClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let settings: JellyfinApiClientSettings
    
    public init(session: URLSession, decoder: JSONDecoder, settings: JellyfinApiClientSettings) {
        self.session = session
        self.decoder = decoder
        self.settings = settings
    }
    
    public func seasons(request: SeasonsRequest) async throws -> SeasonsResponse {
        let url = settings.serverAddress.appending(path: "Shows/\(request.seriesId)/Seasons")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "userId", value: request.userId)
        ]

        var req = URLRequest(url: components.url!)
        req.setValue("MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"", forHTTPHeaderField: "X-Emby-Authorization")
        req.setValue("MediaBrowser Token=\"\(settings.accessToken)\"", forHTTPHeaderField: "Authorization")
        req.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
        
        do {
            return try decoder.decode(SeasonsResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    public func episodes(request: EpisodesRequest) async throws -> EpisodesResponse {
        let url = settings.serverAddress.appending(path: "Shows/\(request.seriesId)/Episodes")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "userId", value: request.userId),
            URLQueryItem(name: "seasonId", value: request.seasonId)
        ]

        var req = URLRequest(url: components.url!)
        req.setValue("MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"", forHTTPHeaderField: "X-Emby-Authorization")
        req.setValue("MediaBrowser Token=\"\(settings.accessToken)\"", forHTTPHeaderField: "Authorization")
        req.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: req)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
        
        do {
            return try decoder.decode(EpisodesResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
