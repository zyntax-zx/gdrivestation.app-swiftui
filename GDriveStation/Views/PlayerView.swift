import SwiftUI

struct PlayerView: View {
    @Bindable var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var backgroundColor: Color = .black
    @State private var isDragging = false
    @State private var shuffleOn = false
    @State private var repeatOn = false
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer()
                albumArt
                Spacer()
                trackInfo
                progressSection
                Spacer()
                playbackControls
                bottomBar
            }
            .padding(.horizontal, 20)
        }
        .offset(y: max(0, dragOffset))
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .updating($dragOffset) { value, state, _ in
                    if value.translation.height > 0 {
                        state = value.translation.height
                    }
                }
                .onEnded { value in
                    let velocity = value.predictedEndTranslation.height
                    if velocity > 200 || dragOffset > 250 {
                        withAnimation(.spring(response: 0.3)) {
                            dismiss()
                        }
                    } else {
                        withAnimation(.spring(response: 0.3)) {
                            _ = dragOffset
                        }
                    }
                }
        )
        .task { await extractColor() }
    }

    // MARK: - Background

    private var background: some View {
        backgroundColor
            .animation(.easeInOut(duration: 0.5), value: backgroundColor)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 0) {
            dragHandle
            HStack {
                artistAvatar
                Spacer()
                lyricsButton
                airPlayButton
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 16)
        }
    }

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.white.opacity(0.3))
            .frame(width: 40, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 20)
    }

    private var artistAvatar: some View {
        ZStack {
            Color.white.opacity(0.15)
            Image(systemName: "person.fill")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
    }

    private var lyricsButton: some View {
        Button(action: {}) {
            Text("Lyrics")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.white.opacity(0.15))
                .clipShape(Capsule())
        }
    }

    private var airPlayButton: some View {
        Button(action: {}) {
            Image(systemName: "airplayaudio")
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.white.opacity(0.15))
                .clipShape(Circle())
        }
    }

    // MARK: - Album Art

    private var albumArt: some View {
        Group {
            if let track = viewModel.player.currentTrack,
               let url = track.coverImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        albumFallback
                    default:
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
                .padding(.horizontal, 8)
            } else {
                albumFallback
            }
        }
    }

    private var albumFallback: some View {
        ZStack {
            Color.white.opacity(0.1)
            Image(systemName: "music.note")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 8)
    }

    // MARK: - Track Info

    private var trackInfo: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(viewModel.player.currentTrack?.title ?? "Not Playing")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                Text(viewModel.player.currentTrack?.artist ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let progress = viewModel.player.progress

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.25))
                        .frame(height: 3)

                    Capsule()
                        .fill(.white)
                        .frame(width: width * progress, height: 3)

                    Circle()
                        .fill(.white)
                        .frame(width: 10, height: 10)
                        .offset(x: width * progress - 5)
                }
                .frame(height: 10)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let fraction = max(0, min(1, value.location.x / width))
                            viewModel.player.seek(to: fraction * viewModel.player.duration)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
            }
            .frame(height: 10)

            HStack {
                Text(formatTime(viewModel.player.currentTime))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
                    .monospacedDigit()
                Spacer()
                Text("-\(formatTime(viewModel.player.duration - viewModel.player.currentTime))")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        HStack(spacing: 0) {
            Button(action: { shuffleOn.toggle() }) {
                Image(systemName: "shuffle")
                    .font(.body)
                    .foregroundStyle(shuffleOn ? .white : .white.opacity(0.4))
            }
            .frame(width: 50)

            Spacer()

            Button(action: { viewModel.player.skipToPrevious() }) {
                Image(systemName: "backward.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .frame(width: 50)

            Spacer()

            Button(action: { viewModel.player.togglePlayback() }) {
                Image(systemName: viewModel.player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.white)
            }
            .frame(width: 70)

            Spacer()

            Button(action: { viewModel.player.skipToNext() }) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .frame(width: 50)

            Spacer()

            Button(action: { repeatOn.toggle() }) {
                Image(systemName: "repeat")
                    .font(.body)
                    .foregroundStyle(repeatOn ? .white : .white.opacity(0.4))
            }
            .frame(width: 50)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Playing from")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                        Text(viewModel.player.currentTrack?.album ?? "Library")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private func formatTime(_ t: Double) -> String {
        let m = Int(abs(t)) / 60
        let s = Int(abs(t)) % 60
        return String(format: "%d:%02d", m, s)
    }

    private func extractColor() async {
        guard let track = viewModel.player.currentTrack,
              let url = track.coverImageURL else { return }
        if let color = await ColorExtractor.dominantColor(from: url) {
            withAnimation {
                backgroundColor = color
            }
        }
    }
}
