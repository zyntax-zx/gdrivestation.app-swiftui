import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: PlayerViewModel
    @State private var showPlayer = false
    @State private var showPlaylistPicker = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            NavigationStack {
                LibraryView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { showPlaylistPicker = true }) {
                                Image(systemName: "list.bullet")
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .sheet(isPresented: $showPlaylistPicker) {
                        playlistPickerSheet
                    }
            }
            .tint(.white)

            VStack {
                Spacer()
                MiniPlayer(viewModel: viewModel) {
                    showPlayer = true
                }
            }
        }
        .overlay {
            if showPlayer {
                PlayerOverlay(isPresented: $showPlayer) {
                    PlayerView(viewModel: viewModel)
                }
                .transition(.opacity)
            }
        }
    }

    private var playlistPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(viewModel.playlistIds, id: \.self) { id in
                    NavigationLink(destination: PlaylistView(viewModel: viewModel, playlistId: id)) {
                        Label(id, systemImage: "list.bullet")
                            .foregroundStyle(.white)
                    }
                }
            }
            .navigationTitle("Playlists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showPlaylistPicker = false }
                        .foregroundStyle(.white)
                }
            }
            .task { await viewModel.loadPlaylistIds() }
        }
    }
}
