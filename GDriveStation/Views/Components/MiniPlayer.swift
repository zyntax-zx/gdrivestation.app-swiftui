import SwiftUI

struct MiniPlayer: View {
    @Bindable var viewModel: PlayerViewModel
    var onTap: () -> Void

    var body: some View {
        if let track = viewModel.player.currentTrack {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    albumArt(for: track)
                    trackInfo(for: track)
                    Spacer()
                    playbackControls
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    private func albumArt(for track: Track) -> some View {
        Group {
            if let url = track.coverImageURL {
                AsyncImage(url: url) { phase in
                    phase.image?
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                ZStack {
                    Color.white.opacity(0.1)
                    Text(track.title.prefix(1).uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    private func trackInfo(for track: Track) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(track.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(track.artist)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 16) {
            Button(action: { viewModel.player.togglePlayback() }) {
                Image(systemName: viewModel.player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            Button(action: { viewModel.player.skipToNext() }) {
                Image(systemName: "forward.fill")
                    .font(.body)
                    .foregroundStyle(.white)
            }
        }
    }
}
