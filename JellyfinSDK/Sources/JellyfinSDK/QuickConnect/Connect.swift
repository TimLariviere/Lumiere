public struct QuickConnectConnectRequest: Sendable, Encodable {
    let secret: String
    
    public init(secret: String) {
        self.secret = secret
    }
}

public struct QuickConnectConnectResponse: Sendable, Decodable {
    public let authenticated: Bool
    public let secret: String
    
    public init(authenticated: Bool, secret: String) {
        self.authenticated = authenticated
        self.secret = secret
    }
}
