import SwiftUI
import Core

@Observable
@MainActor
class ServerSelectionViewModel {
    var isLoading: Bool = false
    var serverAddress: String = ""
    var serverInfoResponse: ServerInfoResponse? = nil
    
    func connect() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let url = URL(string: serverAddress)!
            let serverInfo = try await JellyfinClient.shared.getServerInfo(url: url)
            serverInfoResponse = serverInfo
        } catch {
            
        }
    }
}
