import SwiftUI
import JellyfinSDK

public protocol SetupDependencies: Sendable {
    var jellyfinApiClientSettings: JellyfinApiClientSettings { get }
    var jellyfinApiClient: JellyfinApiClient { get }
}
