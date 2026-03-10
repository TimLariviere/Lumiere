public struct InfoPublicResponse: Sendable, Decodable {
    public let id: String
    public let serverName: String
    public let version: String
    public let startupWizardCompleted: Bool
    
    public init(id: String, serverName: String, version: String, startupWizardCompleted: Bool) {
        self.id = id
        self.serverName = serverName
        self.version = version
        self.startupWizardCompleted = startupWizardCompleted
    }
}
