import SwiftUI
import Core

enum SetupDestination: Hashable {
    case login
}

public struct SetupCoordinator: View {
    @State private var router = Router<SetupDestination>()
    
    let deps: SetupDependencies
    let didLogin: () -> Void
    
    public init(deps: SetupDependencies, didLogin: @MainActor @escaping () -> Void) {
        self.deps = deps
        self.didLogin = didLogin
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            ServerSelectionView(
                deps: deps,
                didConnect: {
                    router.push(.login)
                }
            )
                .navigationDestination(for: SetupDestination.self) { destination in
                    switch destination {
                        case .login:
                            LoginView(deps: deps) {
                                didLogin()
                            }
                    }
                }
                .environment(router)
        }
    }
}
