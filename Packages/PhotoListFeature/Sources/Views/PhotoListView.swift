import ComposableArchitecture
import NukeUI
import SwiftUI

@ViewAction(for: PhotoList.self)
public struct PhotoListView: View {
    @Bindable public var store: StoreOf<PhotoList>

    public init() { self.store = .init(initialState: .loading, reducer: PhotoList.init) }

    init(store: StoreOf<PhotoList>) {
        self.store = store
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Loading your photos...")
                .font(.title2)
        }
        .task { send(.loadPhotos) }
    }

    private func photoRow(author: String, photo: Photo) -> some View {
        HStack(spacing: 0) {
            LazyImage(url: photo.downloadUrl) { phase in
                if let image = phase.image {
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.minPhotoHeight, height: Constants.minPhotoHeight)
                } else {
                    ProgressView()
                }
            }

            Spacer()

            Image(systemName: photo.favorite ? "star.fill" : "star")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.blue)
                .contentTransition(.symbolEffect(.replace))
                .padding(.trailing, 32)
                .onTapGesture {
                    send(.favoriteButtonWasTapped(author: author, id: photo.id))
                }
        }
        .frame(minHeight: Constants.minPhotoHeight)
        .onTapGesture {
            send(.photoRowWasTapped(photoId: photo.id))
        }
    }

    private func photoListView(with state: PhotoList.LoadedState) -> some View {
        List {
            ForEach(state.authorCollections, id: \.self) { collection in
                Section(
                    content: {
                        ForEach(collection.photos, id: \.self) { photo in
                            photoRow(author: collection.author, photo: photo)
                        }
                    },
                    header: { Text(collection.author) }
                )
            }
        }
        .listRowSpacing(8)
    }

    public var body: some View {
        switch store.state {
        case .loading:
            loadingView

        case .loaded(let state):
            photoListView(with: state)
                .sheet(
                    item: $store.scope(state: \.loaded?.photoDetail, action: \.photoDetail),
                    content: PhotoDetailView.init
                )
                .presentationDetents([.large])

        case .error:
            VStack(spacing: 32) {
                Text("We ran into an error, please try again.")
                Button(action: { send(.loadPhotos) }) {
                    Text("Try again")
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - Constants
private enum Constants {
    static let minPhotoHeight: CGFloat = 200
}

// MARK: - Previews
#Preview {
    PhotoListView(store: .init(initialState: .loading, reducer: PhotoList.init))
}
