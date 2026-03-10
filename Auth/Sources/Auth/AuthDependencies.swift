import SwiftUI
import Core

public protocol AuthDependencies: Sendable {
    var jellyfinClient: JellyfinClientProtocol { get }
    var settings: AuthSettings { get }
}
