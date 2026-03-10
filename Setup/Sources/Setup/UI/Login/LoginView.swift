import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    
    let didLogin: () -> Void
    
    init(deps: SetupDependencies, didLogin: @MainActor @escaping () -> Void) {
        self._viewModel = State(initialValue: LoginViewModel(deps: deps))
        self.didLogin = didLogin
    }
    
    var body: some View {
        VStack {
            Text("Account")
                .font(.largeTitle)
            
            if (viewModel.isLoading) {
                Text("Logging in")
            } else if let code = viewModel.quickConnectCode {
                Text("QuickConnect code")
                Text(code)
            } else {
                TextField("Username or email", text: $viewModel.username)
                TextField("Password", text: $viewModel.password)
                
                Button("Log in") {
                    Task { await viewModel.logIn() }
                }
                Button("Quick connect") {
                    Task { await viewModel.initiateQuickConnect() }
                }
            }
        }
        .onReceive(viewModel.didLogin) {
            didLogin()
        }
        .onDisappear {
            viewModel.cancelPolling()
        }
    }
}
