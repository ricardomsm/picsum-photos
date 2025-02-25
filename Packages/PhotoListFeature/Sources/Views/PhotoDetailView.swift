import ComposableArchitecture
import NukeUI
import SwiftUI

@ViewAction(for: PhotoDetail.self)
struct PhotoDetailView: View {
    let store: StoreOf<PhotoDetail>
    private let feedbackGenerator = UIImpactFeedbackGenerator()

    private var favoriteButton: some View {
        let text = store.photo.favorite ? "Unmark as favorite" : "Mark as favorite"
        return Button(
            action: {
                feedbackGenerator.impactOccurred()
                send(.favoriteButtonWasTapped)
            },
            label: { Text(text) }
        )
        .buttonStyle(.bordered)
    }

    var body: some View {
        List {
            Section(
                content: {
                    Text("**Photo Id**: \(store.photo.id.rawValue)")
                    Text("**Author**: \(store.photo.author)")
                    Text("**Original width**: \(store.photo.width)")
                    Text("**Original height**: \(store.photo.height)")
                    Text("**Url**: \(store.photo.url)")
                    Text("**Download Url**: \(store.photo.downloadUrl)")
                },
                header: {
                    LazyImage(url: store.photo.downloadUrl) { state in
                        if let image = state.image {
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(minHeight: 300)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                },
                footer: {
                    HStack {
                        Spacer()
                        favoriteButton
                        Spacer()
                    }
                    .padding(.top, 32)
                }
            )
        }
    }
}

#Preview {
    PhotoDetailView(
        store: .init(
            initialState: PhotoDetail.State(
                photo: .generate(downloadUrl: URL(string: "https://picsum.photos/id/0/5000/3333")!)
            ),
            reducer: PhotoDetail.init
        )
    )
}
