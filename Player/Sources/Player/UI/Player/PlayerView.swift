import SwiftUI
import AVKit

public struct PlayerView: View {
    @State private var viewModel: PlayerViewModel
    
    public init(deps: PlayerDependencies, userId: String, itemId: String) {
        self._viewModel = State(initialValue: PlayerViewModel(deps: deps, userId: userId, itemId: itemId))
    }
    
    public var body: some View {
        ZStack {
            if (viewModel.isLoading) {
                Text("Loading...")
            } else if let player = viewModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                Text("Player")
            }
        }
        .onAppear {
            Task { await viewModel.loadStream() }
        }
        .onChange(of: viewModel.player) {
            viewModel.player?.play()
        }
        .onDisappear() {
            viewModel.player?.pause()
        }
    }
}
