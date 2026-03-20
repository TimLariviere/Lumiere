import SwiftUI
import JellyfinSDK
import Combine
import AVKit

@Observable
@MainActor
class PlayerViewModel {
    var isLoading = false
    var player: AVPlayer? = nil
    
    private let jellyfinApiClient: JellyfinApiClient
    private let userId: String
    private let itemId: String
    
    private var cancellables = Set<AnyCancellable>()
    
    init(deps: PlayerDependencies, userId: String, itemId: String) {
        self.jellyfinApiClient = deps.jellyfinApiClient
        self.userId = userId
        self.itemId = itemId
    }
    
    func loadStream() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let playbackInfoRequest = PlaybackInfoRequest(itemId: itemId, userId: userId)
            let playbackInfoResponse = try await jellyfinApiClient.mediaInfo.playbackInfo(request: playbackInfoRequest)
            let firstMediaSource = playbackInfoResponse.mediaSources.first!
            
            let request = MasterStreamRequest(ItemId: itemId, mediaSourceId: firstMediaSource.id)
            let response = try await jellyfinApiClient.dynamicHls.masterStream(request: request)
            
            let asset = AVURLAsset(
                url: response.url,
                options: [
                    "AVURLAssetHTTPHeaderFieldsKey": response.headers
                ]
            )
            
            let item = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: item)
            
            player?.currentItem?.publisher(for: \.status)
                .sink { status in
                    switch status {
                        case .failed:
                            print("Item failed:", self.player?.currentItem?.error ?? "unknown")
                        case .readyToPlay:
                            print("Ready to play")
                        default: break
                    }
                }
                .store(in: &cancellables)

            // Player errors
            NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime)
                .sink { notification in
                    print("Failed to play:", notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] ?? "")
                }
                .store(in: &cancellables)
            
        } catch {
            print(error)
        }
    }
}
