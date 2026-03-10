import SwiftUI
import Auth
import Core

@main
struct LumiereApp: App {
    let deps = Dependencies()
    let settings = Settings()
    
    var body: some Scene {
        WindowGroup {
            AuthCoordinator(deps: deps)
        }
    }
}

public final class Dependencies: AuthDependencies {
    private let _jellyfinClient: JellyfinClientProtocol
    private let _settings: AuthSettings
    
    init() {
        self._jellyfinClient = JellyfinClient()
        self._settings = Settings()
    }
    
    public var jellyfinClient: JellyfinClientProtocol { self._jellyfinClient }
    public var settings: AuthSettings { self._settings }
}

public final class Settings: AuthSettings {
    private static let jellyfinServerAddressKey = "jellyfinServerAddress"
    public var jellyfinServerAddress: String? {
        get { UserDefaults.standard.string(forKey: Settings.jellyfinServerAddressKey) }
        set { UserDefaults.standard.set(newValue, forKey: Settings.jellyfinServerAddressKey) }
    }
    
    private static let jellyfinServerNameKey = "jellyfinServerName"
    public var jellyfinServerName: String? {
        get { UserDefaults.standard.string(forKey: Settings.jellyfinServerNameKey) }
        set { UserDefaults.standard.set(newValue, forKey: Settings.jellyfinServerNameKey) }
    }
}
