import SwiftUI
import Setup
import Library
import Player
import JellyfinSDK

@main
struct LumiereApp: App {
    let deps = Dependencies()
    
    var body: some Scene {
        WindowGroup {
            AppCoordinator(deps: deps)
        }
    }
}

public final class Dependencies: SetupDependencies, LibraryDependencies, PlayerDependencies {
    private let _settings: Settings
    private let _jellyfinApiClient: JellyfinApiClient
    
    init() {
        self._settings = Settings()
        self._jellyfinApiClient = DefaultJellyfinApiClient(settings: self._settings)
    }
    
    public var jellyfinApiClientSettings: JellyfinApiClientSettings { _settings }
    public var jellyfinApiClient: JellyfinApiClient { _jellyfinApiClient }
}

public final class Settings: JellyfinApiClientSettings {
    private static let serverIdKey = "JellyfinApiClientSettings_ServerId"
    public var serverId: String { UserDefaults.standard.string(forKey: Settings.serverIdKey) ?? "" }
    
    private static let serverNameKey = "JellyfinApiClientSettings_ServerName"
    public var serverName: String { UserDefaults.standard.string(forKey: Settings.serverNameKey) ?? "" }
    
    private static let serverAddressKey = "JellyfinApiClientSettings_ServerAddress"
    public var serverAddress: URL { UserDefaults.standard.url(forKey: Settings.serverAddressKey) ?? URL(string: "/")! }
    
    private static let accessTokenKey = "JellyfinApiClientSettings_AccessToken"
    public var accessToken: String { UserDefaults.standard.string(forKey: Settings.accessTokenKey) ?? "" }
    
    public func setServerAddress(url: URL) {
        UserDefaults.standard.set(url, forKey: Settings.serverAddressKey)
    }
    
    public func setServer(id: String, name: String) {
        UserDefaults.standard.set(id, forKey: Settings.serverIdKey)
        UserDefaults.standard.set(name, forKey: Settings.serverNameKey)
    }
    
    public func setAccessToken(accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Settings.accessTokenKey)
    }
}
