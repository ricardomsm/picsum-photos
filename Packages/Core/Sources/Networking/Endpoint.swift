import HTTPTypes

public enum Endpoint: Sendable {
    case fetchPhotos
    case fetchPhotoDetail(id: String)
}

extension Endpoint {
    var baseUrl: String { "picsum.photos" }

    var method: HTTPRequest.Method {
        switch self {
        case .fetchPhotos,
            .fetchPhotoDetail:
            .get
        }
    }

    var path: String {
        switch self {
        case .fetchPhotos:
            "/v2/list"
        case .fetchPhotoDetail(let id):
            "/id/\(id)/info"
        }
    }

    var request: HTTPRequest {
        .init(
            method: method,
            scheme: "https",
            authority: baseUrl,
            path: path,
            headerFields: [.contentType: "application/json"]
        )
    }
}
