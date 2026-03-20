public struct SeasonsRequest: Sendable {
    public let seriesId: String
    public let userId: String
    
    public init(seriesId: String, userId: String) {
        self.seriesId = seriesId
        self.userId = userId
    }
}

public struct SeasonsResponse: Sendable, Decodable {
    public let items: [Item]
}
