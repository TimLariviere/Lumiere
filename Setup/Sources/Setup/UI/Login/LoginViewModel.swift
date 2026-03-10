import SwiftUI
import Combine
import JellyfinSDK

@Observable
@MainActor
class LoginViewModel {
    var isLoading: Bool = false
    var quickConnectCode: String? = nil
    var username: String = ""
    var password: String = ""
    
    let didLogin = PassthroughSubject<Void, Never>()
    
    private let jellyfinApiClientSettings: JellyfinApiClientSettings
    private let jellyfinApiClient: JellyfinApiClient
    private var pollingTask: Task<Void, Never>?
    
    init(deps: SetupDependencies) {
        self.jellyfinApiClientSettings = deps.jellyfinApiClientSettings
        self.jellyfinApiClient = deps.jellyfinApiClient
    }
    
    func logIn() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = UsersAuthenticateByNameRequest(username: username, pw: password)
            let response = try await jellyfinApiClient.users.authenticateByName(request: request)
            jellyfinApiClientSettings.setAccessToken(accessToken: response.accessToken)
            didLogin.send()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func initiateQuickConnect() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let initiateResponse = try await jellyfinApiClient.quickConnect.initiate()
            quickConnectCode = initiateResponse.code
            startPolling(secret: initiateResponse.secret)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func startPolling(secret: String) {
        pollingTask = Task {
            let request = QuickConnectConnectRequest(secret: secret)
            do {
                while true {
                    try Task.checkCancellation()
                    let connectResponse = try await jellyfinApiClient.quickConnect.connect(request: request)
                    if connectResponse.authenticated {
                        let authenticateRequest = UsersAuthenticateWithQuickConnectRequest(secret: connectResponse.secret)
                        let authenticateResponse = try await jellyfinApiClient.users.authenticateWithQuickConnect(request: authenticateRequest)
                        jellyfinApiClientSettings.setAccessToken(accessToken: authenticateResponse.accessToken)
                        didLogin.send()
                        return
                    }
                    try await Task.sleep(for: .seconds(1))
                }
            } catch is CancellationError {
                // task was cancelled, do nothing
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func cancelPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        isLoading = false
    }
}
