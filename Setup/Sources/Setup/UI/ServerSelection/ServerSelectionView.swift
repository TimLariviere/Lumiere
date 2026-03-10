import SwiftUI
import Core
import DesignSystem

struct ServerSelectionView: View {
    private let didConnect: () -> Void
    
    @State private var viewModel: ServerSelectionViewModel
    
    init(deps: SetupDependencies, didConnect: @MainActor @escaping () -> Void) {
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
