import ComposableArchitecture

@Reducer
public struct PhotoDetail: Sendable {
    @ObservableState
    public struct State: Equatable {
        var photo: Photo
    }

    public enum Action: ViewAction {
        case view(View)

        public enum View {
            case favoriteButtonWasTapped
        }
    }

    public var body: some ReducerOf<PhotoDetail> {
        Reduce { state, action in
            switch action {
            case .view(.favoriteButtonWasTapped):
                state.photo.favorite.toggle()
                return .none
            }
        }
    }
}
