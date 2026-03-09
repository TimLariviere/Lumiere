import SwiftUI
import Core
import DesignSystem

public struct ServerSelectionView: View {
    @State private var viewModel = ServerSelectionViewModel()
    
    public init() {}
    
    public var body: some View {
        VStack {
            Text("Server selection")
                .font(.largeTitle)
            
            if (viewModel.isLoading) {
                Text("Connecting to \(viewModel.serverAddress)...")
            } else if let serverInfo = viewModel.serverInfoResponse {
                Text("Found server at \(viewModel.serverAddress): Name '\(serverInfo.serverName)', Version = '\(serverInfo.version)'")
            } else {
                TextField("Server address (eg. https://jellyfin.domain.com", text: $viewModel.serverAddress)
                
                Button("Connect") {
                    Task { await viewModel.connect() }
                }
            }
            
        }
    }
}
