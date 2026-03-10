import SwiftUI
import Core
import DesignSystem

public struct ServerSelectionView: View {
    private let didConnect: () -> Void
    
    @State private var viewModel: ServerSelectionViewModel
    
    public init(deps: AuthDependencies, didConnect: @MainActor @escaping () -> Void) {
        self.didConnect = didConnect
        _viewModel = State(initialValue: ServerSelectionViewModel(deps: deps))
    }
    
    public var body: some View {
        VStack {
            Text("Server selection")
                .font(.largeTitle)
            
            if (viewModel.isLoading) {
                Text("Connecting to \(viewModel.serverAddress)...")
            } else {
                TextField("Server address", text: $viewModel.serverAddress)
                
                Button("Connect") {
                    Task { await viewModel.connect() }
                }
            }
        }
        .onReceive(viewModel.didConnect) {
            didConnect()
        }
    }
}

#Preview {
    ServerSelectionView(deps: MockAuthDependencies.shared, didConnect: {})
}
