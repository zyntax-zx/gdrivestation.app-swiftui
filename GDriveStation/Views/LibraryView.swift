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
                    .font(DesignTokens.Typography.tertiaryFont)
                Text("Play All")
                    .font(DesignTokens.Typography.secondaryFont)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white.opacity(DesignTokens.Opacity.primary))
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(Color.white.opacity(DesignTokens.Opacity.ghost))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.container))
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(
            top: DesignTokens.Spacing.sm,
            leading: DesignTokens.Spacing.lg,
            bottom: DesignTokens.Spacing.sm,
            trailing: DesignTokens.Spacing.lg
        ))
    }
}
