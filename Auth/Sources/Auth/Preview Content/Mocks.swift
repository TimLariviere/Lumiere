import Core
import Foundation

final class MockJellyfinClient: JellyfinClientProtocol {
    func getServerInfo(url: URL) async throws -> ServerInfoResponse {
        return ServerInfoResponse(
            id: "abcdefg",
            serverName: "Server name",
            version: "1.0.0",
            startupWizardCompleted: true
        )
    }
    
    func authenticateByName(baseURL: URL, token: String, request: Core.UsersAuthenticateByNameRequest) async throws -> Core.UsersAuthenticateByNameResponse {
        return UsersAuthenticateByNameResponse(user: UsersAuthenticateByNameResponse_User(id: "user_id"))
    }
    
    
}

final class MockAuthDependencies: AuthDependencies {
    static let shared = MockAuthDependencies()
    
    let _jellyfinClient = MockJellyfinClient()
    var jellyfinClient: JellyfinClientProtocol { _jellyfinClient }
    
    let _settings = MockAuthSettings()
    var settings: AuthSettings { _settings }
}

final class MockAuthSettings: AuthSettings {
    static let shared = MockAuthSettings()
    
    nonisolated(unsafe) var _jellyfinServerAddress: String? = "http://jellyfin"
    var jellyfinServerAddress: String? {
        get { _jellyfinServerAddress }
        set { _jellyfinServerAddress = newValue }
    }
    
    nonisolated(unsafe) var _jellyfinServerName: String? = "MyServer"
    var jellyfinServerName: String? {
        get { _jellyfinServerName }
        set { _jellyfinServerName = newValue }
    }
}
