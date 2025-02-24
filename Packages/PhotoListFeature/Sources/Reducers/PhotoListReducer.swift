import ComposableArchitecture

@Reducer
public struct PhotoList: Sendable {
    @ObservableState
    @CasePathable
    public enum State: Equatable {
        case loading
        case loaded(LoadedState)
        case error
    }

    @ObservableState
    public struct LoadedState: Equatable {
        let authors: [String]
        var photosByAuthor: [String: [Photo]]
        @Presents var photoDetail: PhotoDetail.State?

        var authorCollections: [AuthorCollection] { photosByAuthor.map { AuthorCollection(author: $0, photos: $1) } }
    }

    public enum Action: ViewAction {
        case view(View)
        case photoResponse([Photo])
        case errorResponse
        case photoDetailResponse(Photo)
        case photoDetail(PresentationAction<PhotoDetail.Action>)

        public enum View {
            case loadPhotos
            case favoriteButtonWasTapped(author: String, id: Photo.Id)
            case photoRowWasTapped(photoId: Photo.Id)
        }
    }

    @ObservationIgnored @Dependency(\.photosService) private var photosService

    public var body: some ReducerOf<PhotoList> {
        Reduce { state, action in
            switch action {
            case .view(.loadPhotos):
                state = .loading
                return .run { send in
                    let photos = try await self.photosService.fetchPhotos()
                    await send(.photoResponse(photos))
                } catch: { error, send in
                    print(error)
                    await send(.errorResponse)
                }

            case let .view(.favoriteButtonWasTapped(author, photoId)):
                state.loaded?
                    .photosByAuthor[author]?
                    .firstIndex(where: { $0.id == photoId })
                    .map { index in
                        state.modify(\.loaded) { loaded in
                            print(loaded)
                            loaded.photosByAuthor[author]?[index].favorite.toggle()
                            print(loaded)
                        }
                    }

                return .none

            case .view(.photoRowWasTapped(let photoId)):
                return .run(
                    operation: { send in
                        let photoDetail = try await self.photosService.fetchPhotoDetail(photoId.rawValue)
                        await send(.photoDetailResponse(photoDetail))
                    },
                    catch: { error, send in
                        print(error)
                        await send(.errorResponse)
                    }
                )

            case .photoResponse(let photos):
                let authorsAndPhotos = photos.reduce(into: [String: [Photo]]()) { result, photo in
                    guard result[photo.author] == nil else {
                        result[photo.author]?.append(photo)
                        return
                    }

                    result[photo.author] = [photo]
                }

                state = .loaded(.init(authors: Array(authorsAndPhotos.keys), photosByAuthor: authorsAndPhotos))
                return .none

            case .photoDetailResponse(var photo):
                state.loaded?
                    .photosByAuthor[photo.author]?
                    .first { $0.id == photo.id }
                    .map { currentPhoto in
                        photo.favorite = currentPhoto.favorite
                        state.modify(\.loaded) { loaded in
                            loaded.photoDetail = PhotoDetail.State(photo: photo)
                        }
                    }

                return .none

            case .errorResponse:
                state = .error
                return .none

            case .photoDetail(.presented(.view(.favoriteButtonWasTapped))):
                guard
                    let loadedState = state.loaded,
                    let author = loadedState.photoDetail?.photo.author,
                    let photo = loadedState.photoDetail?.photo,
                    let index = loadedState.photosByAuthor[author]?.firstIndex(where: { $0.id == photo.id })
                else { return .none }

                state.modify(\.loaded) { $0.photosByAuthor[author]?[index].favorite = photo.favorite }

                return .none

            case .photoDetail(.dismiss):
                return .none
            }
        }
        .ifLet(\.loaded, action: \.photoDetail) {
            EmptyReducer()
                .ifLet(\.$photoDetail, action: \.self, destination: PhotoDetail.init)
        }
    }
}
