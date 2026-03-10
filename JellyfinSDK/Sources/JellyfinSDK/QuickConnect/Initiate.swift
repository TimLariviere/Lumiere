public struct QuickConnectInitiateResponse: Sendable, Decodable {
    public let secret: String
    public let code: String
    
    public init(secret: String, code: String) {
        self.secret = secret
        self.code = code
    }
}
