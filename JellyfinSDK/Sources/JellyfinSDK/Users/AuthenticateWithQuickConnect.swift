public struct UsersAuthenticateWithQuickConnectRequest: Sendable, Encodable {
    let secret: String
    
    public init(secret: String) {
        self.secret = secret
    }
}

public struct UsersAuthenticateWithQuickConnectResponse: Sendable, Decodable {
    public let user: UsersAuthenticateWithQuickConnectResponse_User
    public let accessToken: String
    
    public init(user: UsersAuthenticateWithQuickConnectResponse_User, accessToken: String) {
        self.user = user
        self.accessToken = accessToken
    }
}

public struct UsersAuthenticateWithQuickConnectResponse_User: Sendable, Decodable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}
