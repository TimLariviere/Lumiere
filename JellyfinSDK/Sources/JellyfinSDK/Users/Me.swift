public struct UsersMeResponse: Sendable, Decodable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
