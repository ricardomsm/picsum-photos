import Foundation
import Tagged

public struct Photo: Decodable, Hashable, Identifiable {
    public let id: Id
    public let author: String
    public let width: Int
    public let height: Int
    public let url: URL
    public let downloadUrl: URL
    public var favorite = false
}

// MARK: - Coding keys
extension Photo {
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case url
        case downloadUrl = "download_url"
    }
}

// MARK: - Tagged
extension Photo {
    public typealias Id = Tagged<(Photo, id: ()), String>
}

// MARK: - Mocks
extension Photo {
    static func generate(
        id: Id = .init("0"),
        author: String = "Michael Angelo",
        width: Int = 0,
        height: Int = 0,
        url: URL = .init(string: "htttps://test.com")!,
        downloadUrl: URL = .init(string: "htttps://test.com")!,
        favorite: Bool = false
    ) -> Self {
        .init(
            id: id,
            author: author,
            width: width,
            height: height,
            url: url,
            downloadUrl: downloadUrl,
            favorite: favorite
        )
    }
}
