import SwiftUI

struct PlaylistView: View {
    @Bindable var viewModel: PlayerViewModel
    let playlistId: String

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading playlist...")
            } else if let playlist = viewModel.currentPlaylist {
                playlistContent(playlist)
            } else {
                ContentUnavailableView(
                    "Not Found",
                    systemImage: "list.bullet",
                    description: Text("Playlist could not be loaded")
                )
            }
        }
        .navigationTitle(viewModel.currentPlaylist?.name ?? "Playlist")
        .task { await viewModel.loadPlaylist(id: playlistId) }
    }

    private func playlistContent(_ playlist: Playlist) -> some View {
        List {
            headerSection(playlist)
            ForEach(playlist.tracks) { track in
                TrackRow(
                    track: track,
                    isPlaying: viewModel.player.currentTrack?.id == track.id
                )
                .onTapGesture {
                    viewModel.playTrack(track)
                }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }

    private func headerSection(_ playlist: Playlist) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !playlist.description.isEmpty {
                Text(playlist.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            Text("\(playlist.tracks.count) tracks")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
}
