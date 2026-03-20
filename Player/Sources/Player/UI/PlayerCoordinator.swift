import SwiftUI
import Core

enum PlayerDestination: Hashable {
    
}

public struct PlayerCoordinator: View {
    @State private var router = Router<PlayerDestination>()
    
    private let deps: PlayerDependencies
    private let userId: String
    private let itemId: String
    
    public init(deps: PlayerDependencies, userId: String, itemId: String) {
        self.deps = deps
        self.userId = userId
        self.itemId = itemId
    }
    
    public var body: some View {
        PlayerView(
            deps: deps,
            userId: userId,
            itemId: itemId
        )
            .environment(router)
    }
}
