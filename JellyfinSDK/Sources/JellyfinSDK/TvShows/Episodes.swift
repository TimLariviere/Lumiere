public struct EpisodesRequest: Sendable {
    public let seriesId: String
    public let userId: String
    public let seasonId: String
    
    public init(seriesId: String, userId: String, seasonId: String) {
        self.seriesId = seriesId
        self.userId = userId
        self.seasonId = seasonId
    }
}

public struct EpisodesResponse: Sendable, Decodable {
    public let items: [Item]
}
