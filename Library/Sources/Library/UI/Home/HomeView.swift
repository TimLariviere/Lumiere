import SwiftUI

public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    private let didLogOut: () -> Void
    
    public init(deps: LibraryDependencies, didLogOut: @MainActor @escaping () -> Void) {
        self._viewModel = State(initialValue: HomeViewModel(deps: deps))
        self.didLogOut = didLogOut
    }
    
    public var body: some View {
        VStack {
            Text("Home")
            Text(viewModel.info)
            Button("Log out") {
                didLogOut()
            }
        }
        .onAppear {
            Task { await viewModel.getMe() }
        }
    }
}
