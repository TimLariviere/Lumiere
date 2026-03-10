import SwiftUI
import Setup
import Library

struct AppCoordinator: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    private let deps: Dependencies
    
    init(deps: Dependencies) {
        self.deps = deps
    }
    
    var body: some View {
        Group {
            if (isLoggedIn) {
                LibraryCoordinator(
                    deps: deps,
                    didLogOut: {
                        isLoggedIn = false
                    }
                )
            } else {
                SetupCoordinator(
                    deps: deps,
                    didLogin: {
                        isLoggedIn = true
                    }
                )
            }
        }
    }
}
