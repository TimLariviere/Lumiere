import Foundation

public protocol JellyfinApiClient: Sendable {
    var users: UsersClient { get }
    var userLibrary: UserLibraryClient { get }
    var quickConnect: QuickConnectClient { get }
    var system: SystemClient { get }
    var dynamicHls: DynamicHlsClient { get }
    var mediaInfo: MediaInfoClient { get }
    var tvShows: TvShowsClient { get }
}

public protocol JellyfinApiClientSettings: Sendable {
    var serverId: String { get }
    var serverName: String { get }
    var serverAddress: URL { get }
    var accessToken: String { get }
    
    func setServerAddress(url: URL)
    func setServer(id: String, name: String)
    func setAccessToken(accessToken: String)
}

public final class DefaultJellyfinApiClient: JellyfinApiClient {
    private let _users: UsersClient
    private let _userLibrary: UserLibraryClient
    private let _quickConnect: QuickConnectClient
    private let _system: SystemClient
    private let _dynamicHls: DynamicHlsClient
    private let _mediaInfo: MediaInfoClient
    private let _tvShows: TvShowsClient
    
    public var users: UsersClient { _users }
    public var userLibrary: UserLibraryClient { _userLibrary }
    public var quickConnect: QuickConnectClient { _quickConnect }
    public var system: SystemClient { _system }
    public var dynamicHls: DynamicHlsClient { _dynamicHls }
    public var mediaInfo: MediaInfoClient { _mediaInfo }
    public var tvShows: TvShowsClient { _tvShows }
    
    public init(settings: JellyfinApiClientSettings) {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Accept": "application/json"]
        let session = URLSession(configuration: config)
        
        let decoder = JSONDecoder.pascalCaseDecoder()
        let settings = settings
        
        self._users = DefaultUsersClient(session: session, decoder: decoder, settings: settings)
        self._userLibrary = DefaultUserLibraryClient(session: session, decoder: decoder, settings: settings)
        self._quickConnect = DefaultQuickConnectClient(session: session, decoder: decoder, settings: settings)
        self._system = DefaultSystemClient(session: session, decoder: decoder, settings: settings)
        self._dynamicHls = DefaultDynamicHlsClient(session: session, decoder: decoder, settings: settings)
        self._mediaInfo = DefaultMediaInfoClient(session: session, decoder: decoder, settings: settings)
        self._tvShows = DefaultTvShowsClient(session: session, decoder: decoder, settings: settings)
    }
}
