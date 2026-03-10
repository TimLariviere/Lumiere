import SwiftUI
import Combine
import JellyfinSDK

@Observable
@MainActor
class ServerSelectionViewModel {
    private let jellyfinApiClientSettings: JellyfinApiClientSettings
    private let jellyfinApiClient: JellyfinApiClient
    
    var isLoading: Bool = false
    var serverAddress: String = ""
    
    let didConnect = PassthroughSubject<Void, Never>()
    
    init(deps: SetupDependencies) {
        self.jellyfinApiClientSettings = deps.jellyfinApiClientSettings
        self.jellyfinApiClient = deps.jellyfinApiClient
        
        serverAddress = self.jellyfinApiClientSettings.serverAddress.relativePath
    }
    
    func connect() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let url = URL(string: serverAddress)!
            jellyfinApiClientSettings.setServerAddress(url: url)
            let serverInfo = try await jellyfinApiClient.system.infoPublic()
            jellyfinApiClientSettings.setServer(id: serverInfo.id, name: serverInfo.serverName)
            didConnect.send()
        } catch {
            print(error.localizedDescription)
        }
    }
}
