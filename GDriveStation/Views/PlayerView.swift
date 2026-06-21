import SwiftUI

struct PlayerView: View {
    @Bindable var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var backgroundColor: Color = .black
    @State private var isDragging = false
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            gradientBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                dragHandle
                Spacer()
                albumArt
                Spacer()
                trackInfo
                Spacer()
                progressSection
                Spacer()
                playbackControls
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
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
        .task {
            await extractColor()
        }
    }

    private var gradientBackground: some View {
        LinearGradient(
            colors: [backgroundColor, backgroundColor.opacity(0.6), .black],
            startPoint: .top,
            endPoint: .bottom
        )
        .animation(.easeInOut(duration: 0.5), value: backgroundColor)
    }

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.white.opacity(0.3))
            .frame(width: 40, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 24)
    }

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
                .frame(width: 280, height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
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
        .frame(width: 280, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var trackInfo: some View {
        VStack(spacing: 6) {
            Text(viewModel.player.currentTrack?.title ?? "Not Playing")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(viewModel.player.currentTrack?.artist ?? "")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
        }
    }

    private var progressSection: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let progress = viewModel.player.progress

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.2))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white)
                        .frame(width: width * progress, height: 4)
                }
                .frame(height: 4)
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
            .frame(height: 20)

            HStack {
                Text(formatTime(viewModel.player.currentTime))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .monospacedDigit()
                Spacer()
                Text(formatTime(viewModel.player.duration))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .monospacedDigit()
            }
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 40) {
            Button(action: { viewModel.player.skipToPrevious() }) {
                Image(systemName: "backward.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            Button(action: { viewModel.player.togglePlayback() }) {
                Image(systemName: viewModel.player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white)
            }

            Button(action: { viewModel.player.skipToNext() }) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
    }

    private func formatTime(_ t: Double) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
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
