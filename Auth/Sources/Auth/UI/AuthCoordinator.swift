import SwiftUI
import Core

enum AuthDestination: Hashable {
    case login
}

public struct AuthCoordinator: View {
    @State private var router = Router<AuthDestination>()
    
    let deps: AuthDependencies
    
    public init(deps: AuthDependencies) {
        self.deps = deps
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            ServerSelectionView(
                deps: deps,
                didConnect: {
                    router.push(.login)
                }
            )
                .navigationDestination(for: AuthDestination.self) { destination in
                    switch destination {
                        case .login: LoginView()
                    }
                }
                .environment(router)
        }
    }
}

#Preview {
    AuthCoordinator(
        deps: MockAuthDependencies.shared
    )
}
