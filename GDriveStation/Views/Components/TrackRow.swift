import SwiftUI

struct TrackRow: View {
    let track: Track
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 12) {
            albumArt
            trackInfo
            Spacer()
            duration
        }
        .padding(.vertical, 4)
        .background(isPlaying ? Color.white.opacity(0.05) : Color.clear)
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
                .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                fallbackArt
            }
        }
    }

    private var fallbackArt: some View {
        ZStack {
            Color.white.opacity(0.1)
            Text(track.title.prefix(1).uppercased())
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var trackInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(track.title)
                .font(.subheadline)
                .fontWeight(isPlaying ? .semibold : .regular)
                .foregroundStyle(isPlaying ? .white : .white.opacity(0.9))
                .lineLimit(1)

            Text(track.artist)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
        }
    }

    private var duration: some View {
        Text(track.durationFormatted)
            .font(.caption)
            .foregroundStyle(.white.opacity(0.4))
            .monospacedDigit()
    }
}
