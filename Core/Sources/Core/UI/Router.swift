import SwiftUI

@MainActor @Observable public final class Router<Screen: Hashable> {
    public var path: [Screen] = []
    
    public init() {}

    public func push(_ screen: Screen) {
        path.append(screen)
    }

    public func pop() {
        _ = path.popLast()
    }

    public func reset() {
        path.removeAll()
    }
}
