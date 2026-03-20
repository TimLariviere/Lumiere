import SwiftUI
import Setup
import Library
import Player

struct AppCoordinator: View {
    @AppStorage("userId") private var userId: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var selectedItemId: String? = nil
    
    private let deps: Dependencies
    
    init(deps: Dependencies) {
        self.deps = deps
    }
    
    var body: some View {
        Group {
            if (self.isLoggedIn) {
                if let selectedItemId = self.selectedItemId {
                    PlayerCoordinator(
                        deps: deps,
                        userId: self.userId,
                        itemId: selectedItemId
                    )
                } else {
                    LibraryCoordinator(
                        deps: deps,
                        didLogOut: {
                            self.isLoggedIn = false
                        },
                        didSelectMovie: { movieId in
                            self.selectedItemId = movieId
                        }
                    )
                }
            } else {
                SetupCoordinator(
                    deps: deps,
                    didLogin: { userId in
                        self.userId = userId
                        self.isLoggedIn = true
                    }
                )
            }
        }
    }
}
