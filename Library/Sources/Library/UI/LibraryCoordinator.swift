import SwiftUI
import Core

enum LibraryDestination: Hashable {
    
}

public struct LibraryCoordinator: View {
    @State private var router = Router<LibraryDestination>()
    
    private let deps: LibraryDependencies
    private let didLogOut: () -> Void
    private let didSelectMovie: (String) -> Void
    
    public init(deps: LibraryDependencies, didLogOut: @MainActor @escaping () -> Void, didSelectMovie: @MainActor @escaping (String) -> Void) {
        self.deps = deps
        self.didLogOut = didLogOut
        self.didSelectMovie = didSelectMovie
    }
    
    public var body: some View {
        HomeView(
            deps: deps,
            didLogOut: { didLogOut() },
            didSelectMovie: { id in didSelectMovie(id) }
        )
            .environment(router)
    }
}
