import Dependencies
import Foundation
import HTTPTypesFoundation

public struct NetworkingClient: Sendable {
    let call: @Sendable (Endpoint) async throws(NetworkError) -> Data
}

// MARK: - Implementations
extension NetworkingClient {
    static func live(urlSession: URLSession = .init(configuration: .default)) -> Self {
        .init(
            call: { endpoint async throws(NetworkError) -> Data in
                let response = try? await urlSession.data(for: endpoint.request)

                guard let (data, httpResponse) = response else {
                    throw NetworkError(code: 0, description: "No response")
                }

                guard httpResponse.status.kind == .successful else {
                    throw NetworkError(code: httpResponse.status.code, description: httpResponse.status.description)

                }

                return data
            }
        )
    }

    public func call<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder = .init()) async throws -> T {
        let data = try await call(endpoint)
        return try decoder.decode(T.self, from: data)
    }

    static func mock(call: @Sendable @escaping (Endpoint) async throws(NetworkError) -> Data = { _ in Data()}) -> Self {
        .init(call: call)
    }
}

// MARK: - Dependency registry
extension NetworkingClient: DependencyKey {
    public static let liveValue = NetworkingClient.live()
    public static let testValue = NetworkingClient.mock()
}

extension DependencyValues {
    public var networkingClient: NetworkingClient {
        get { self[NetworkingClient.self] }
        set { self[NetworkingClient.self] = newValue }
    }
}
