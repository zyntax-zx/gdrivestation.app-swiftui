import SwiftUI

struct MiniPlayer: View {
    @Bindable var viewModel: PlayerViewModel
    var onTap: () -> Void

    var body: some View {
        if let track = viewModel.player.currentTrack {
            Button(action: onTap) {
                HStack(spacing: DesignTokens.Spacing.md) {
                    albumArt(for: track)
                    trackInfo(for: track)
                    Spacer()
                    playbackControls
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sheet))
                .shadow(
                    color: DesignTokens.Shadow.sm.color,
                    radius: DesignTokens.Shadow.sm.radius,
                    y: DesignTokens.Shadow.sm.y
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.bottom, DesignTokens.Spacing.sm)
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
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.artwork))
            } else {
                ZStack {
                    Color.white.opacity(DesignTokens.Opacity.ghost)
                    Text(track.title.prefix(1).uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.artwork))
            }
        }
    }

    private func trackInfo(for track: Track) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(track.title)
                .font(DesignTokens.Typography.titleFont)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(DesignTokens.Opacity.primary))
                .lineLimit(1)
            Text(track.artist)
                .font(DesignTokens.Typography.secondaryFont)
                .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
                .lineLimit(1)
        }
    }

    private var playbackControls: some View {
        HStack(spacing: DesignTokens.Spacing.lg) {
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
