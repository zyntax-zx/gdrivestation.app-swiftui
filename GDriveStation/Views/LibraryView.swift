import SwiftUI

struct LibraryView: View {
    @Bindable var viewModel: PlayerViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.tracks.isEmpty {
                ProgressView("Loading library...")
            } else if viewModel.tracks.isEmpty {
                ContentUnavailableView(
                    "No Tracks",
                    systemImage: "music.note",
                    description: Text("Pull to refresh to load your library")
                )
            } else {
                trackList
            }
        }
        .navigationTitle("Library")
        .task { await viewModel.loadLibrary() }
        .refreshable { await viewModel.refresh() }
    }

    private var trackList: some View {
        List {
            playAllButton
            ForEach(viewModel.tracks) { track in
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

    private var playAllButton: some View {
        Button(action: { viewModel.playAll() }) {
            HStack {
                Image(systemName: "play.fill")
                    .font(.caption)
                Text("Play All")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}
