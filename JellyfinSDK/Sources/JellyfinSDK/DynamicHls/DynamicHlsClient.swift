import Foundation

public protocol DynamicHlsClient: Sendable {
    func masterStream(request: MasterStreamRequest) async throws -> MasterStreamResponse
}

public actor DefaultDynamicHlsClient: DynamicHlsClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let settings: JellyfinApiClientSettings
    
    init(session: URLSession, decoder: JSONDecoder, settings: JellyfinApiClientSettings) {
        self.session = session
        self.decoder = decoder
        self.settings = settings
    }
    
    public func masterStream(request: MasterStreamRequest) async throws -> MasterStreamResponse {
        let url = settings.serverAddress.appending(path: "Videos/\(request.ItemId)/master.m3u8")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "mediaSourceId", value: request.mediaSourceId),
            URLQueryItem(name: "audioCodec", value: "aac"),
            URLQueryItem(name: "videoCodec", value: "h264"),
            URLQueryItem(name: "container", value: "ts")
        ]
        
        let headers = [
            "X-Emby-Authorization": "MediaBrowser Client=\"Lumiere\", Device=\"AppleTV\", DeviceId=\"apple-tv-simulator\", Version=\"0.0.1\"",
            "Authorization": "MediaBrowser Token=\"\(settings.accessToken)\""
        ]
        
        return MasterStreamResponse(headers: headers, url: components.url!)
    }
}
