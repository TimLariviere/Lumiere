public struct PlaybackInfoRequest: Sendable {
    let itemId: String
    let userId: String
    
    public init(itemId: String, userId: String) {
        self.itemId = itemId
        self.userId = userId
    }
}

public struct PlaybackInfoResponse: Sendable, Decodable {
    public let mediaSources: [MediaSource]
}

public struct MediaSource: Sendable, Decodable {
    public let id: String
}
