import SwiftUI

public protocol AuthSettings: AnyObject, Sendable {
    var jellyfinServerAddress: String? { get set }
    var jellyfinServerName: String? { get set }
}
