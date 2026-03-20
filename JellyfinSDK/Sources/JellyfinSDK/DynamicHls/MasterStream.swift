import Foundation

public struct MasterStreamRequest: Sendable {
    let ItemId: String
    let mediaSourceId: String
    
    public init(ItemId: String, mediaSourceId: String) {
        self.ItemId = ItemId
        self.mediaSourceId = mediaSourceId
    }
}

public struct MasterStreamResponse: Sendable {
    public let headers: [String: String]
    public let url: URL
}
