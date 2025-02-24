import Core
import Dependencies

public struct PhotosService: Sendable {
    public let fetchPhotos: @Sendable () async throws -> [Photo]
    public let fetchPhotoDetail: @Sendable (_ id: String) async throws -> Photo
}

// MARK: - Implementations
extension PhotosService {
    static func live(networkClient: NetworkingClient) -> Self {
        .init(
            fetchPhotos: { try await networkClient.call(endpoint: .fetchPhotos) },
            fetchPhotoDetail: { id in
                try await networkClient.call(endpoint: .fetchPhotoDetail(id: id))
            }
        )
    }

    static func mock(
        fetchPhotos: @Sendable @escaping () async throws -> [Photo] = { [] },
        fetchPhotoDetail: @Sendable @escaping (String) async throws -> Photo = { _ in .generate() }
    ) -> Self {
        .init(
            fetchPhotos: fetchPhotos,
            fetchPhotoDetail: fetchPhotoDetail
        )
    }
}

// MARK: - Dependency registry
extension PhotosService: DependencyKey {
    public static let liveValue: PhotosService = {
        @Dependency(\.networkingClient) var networkingClient
        return .live(networkClient: networkingClient)
    }()

    public static let testValue: PhotosService = .mock()
}

extension DependencyValues {
    public var photosService: PhotosService {
        get { self[PhotosService.self] }
        set { self[PhotosService.self] = newValue }
    }
}

