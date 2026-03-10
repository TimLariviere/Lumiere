import SwiftUI
import Combine
import JellyfinSDK

@Observable
@MainActor
class HomeViewModel {
    var isLoading: Bool = false
    var info: String = ""
    
    private let jellyfinApiClient: JellyfinApiClient
    
    init(deps: LibraryDependencies) {
        self.jellyfinApiClient = deps.jellyfinApiClient
    }
    
    func getMe() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await jellyfinApiClient.users.me()
            info = response.name
        } catch {
            print(error.localizedDescription)
        }
    }
}
