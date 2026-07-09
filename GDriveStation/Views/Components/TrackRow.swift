import SwiftUI

struct TrackRow: View {
    let track: Track
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            albumArt
            trackInfo
            Spacer()
            duration
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(isPlaying ? Color.white.opacity(DesignTokens.Opacity.subtle) : Color.clear)
        .contentShape(Rectangle())
    }

    private var albumArt: some View {
        Group {
            if let url = track.coverImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        fallbackArt
                    default:
                        ProgressView()
                            .frame(width: 48, height: 48)
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.artwork))
            } else {
                fallbackArt
            }
        }
    }

    private var fallbackArt: some View {
        ZStack {
            Color.white.opacity(DesignTokens.Opacity.ghost)
            Text(track.title.prefix(1).uppercased())
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.artwork))
    }

    private var trackInfo: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(track.title)
                .font(DesignTokens.Typography.titleFont)
                .fontWeight(isPlaying ? .semibold : DesignTokens.Typography.titleWeight)
                .foregroundStyle(isPlaying ? .white.opacity(DesignTokens.Opacity.primary) : .white.opacity(DesignTokens.Opacity.secondary))
                .lineLimit(1)

            Text(track.artist)
                .font(DesignTokens.Typography.secondaryFont)
                .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
                .lineLimit(1)
        }
    }

    private var duration: some View {
        Text(track.durationFormatted)
            .font(DesignTokens.Typography.tertiaryFont)
            .foregroundStyle(.white.opacity(DesignTokens.Opacity.tertiary))
            .monospacedDigit()
    }
}
