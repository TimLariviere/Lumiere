public struct UsersAuthenticateByNameRequest: Sendable, Encodable {
    let username: String
    let pw: String
    
    public init(username: String, pw: String) {
        self.username = username
        self.pw = pw
    }
}

public struct UsersAuthenticateByNameResponse: Sendable, Decodable {
    public let user: UsersAuthenticateByNameResponse_User
    public let accessToken: String
    
    public init(user: UsersAuthenticateByNameResponse_User, accessToken: String) {
        self.user = user
        self.accessToken = accessToken
    }
}

public struct UsersAuthenticateByNameResponse_User: Sendable, Decodable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}
