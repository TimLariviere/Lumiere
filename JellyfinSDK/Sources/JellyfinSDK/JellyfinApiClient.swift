import Foundation

public protocol JellyfinApiClient: Sendable {
    var users: UsersClient { get }
    var quickConnect: QuickConnectClient { get }
    var system: SystemClient { get }
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
    private let _quickConnect: QuickConnectClient
    private let _system: SystemClient
    
    public var users: UsersClient { _users }
    public var quickConnect: QuickConnectClient { _quickConnect }
    public var system: SystemClient { _system }
    
    public init(settings: JellyfinApiClientSettings) {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Accept": "application/json"]
        let session = URLSession(configuration: config)
        
        let decoder = JSONDecoder.pascalCaseDecoder()
        let settings = settings
        
        self._users = DefaultUsersClient(session: session, decoder: decoder, settings: settings)
        self._quickConnect = DefaultQuickConnectClient(session: session, decoder: decoder, settings: settings)
        self._system = DefaultSystemClient(session: session, decoder: decoder, settings: settings)
    }
}
