import SwiftUI
import Combine
import Core

@Observable
@MainActor
class ServerSelectionViewModel {
    private let jellyfinClient: JellyfinClientProtocol
    private let settings: AuthSettings
    
    var isLoading: Bool = false
    var serverAddress: String = ""
    
    let didConnect = PassthroughSubject<Void, Never>()
    
    init(deps: AuthDependencies) {
        self.jellyfinClient = deps.jellyfinClient
        self.settings = deps.settings
    }
    
    func connect() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let url = URL(string: serverAddress)!
            let serverInfo = try await jellyfinClient.getServerInfo(url: url)
            settings.jellyfinServerAddress = serverAddress
            settings.jellyfinServerName = serverInfo.serverName
            didConnect.send()
        } catch {
            
        }
    }
}
