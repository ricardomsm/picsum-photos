public struct NetworkError: Equatable, Error, Sendable {
    public let code: Int
    public let description: String

    public init(code: Int, description: String) {
        self.code = code
        self.description = description
    }
}
