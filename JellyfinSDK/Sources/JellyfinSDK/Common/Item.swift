public enum ItemType: String, Sendable, Decodable {
    case movie = "Movie"
    case series = "Series"
    case season = "Season"
    case episode = "Episode"
}

public struct Item: Sendable, Decodable {
    public let id: String
    public let name: String
    public let type: ItemType
    
    public let seriesId: String?
    public let seriesName: String?
    
    public let seasonId: String?
    public let seasonName: String?
}
