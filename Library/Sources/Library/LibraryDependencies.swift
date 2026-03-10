import SwiftUI
import JellyfinSDK

public protocol LibraryDependencies: Sendable {
    var jellyfinApiClient: JellyfinApiClient { get }
}
