public struct ItemsLatestRequest: Sendable {
    public let userId: String
    public let parentId: String?
    public let limit: Int
    
    public init(userId: String, parentId: String? = nil, limit: Int = 20) {
        self.userId = userId
        self.parentId = parentId
        self.limit = limit
    }
}
