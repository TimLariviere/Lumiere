import SwiftUI
import Core

enum LibraryDestination: Hashable {
    
}

public struct LibraryCoordinator: View {
    @State private var router = Router<LibraryDestination>()
    
    private let deps: LibraryDependencies
    private let didLogOut: () -> Void
    
    public init(deps: LibraryDependencies, didLogOut: @MainActor @escaping () -> Void) {
        self.deps = deps
        self.didLogOut = didLogOut
    }
    
    public var body: some View {
        HomeView(
            deps: deps,
            didLogOut: { didLogOut() }
        )
            .environment(router)
    }
}
