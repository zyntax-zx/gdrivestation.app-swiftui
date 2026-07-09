import SwiftUI

struct PlayerView: View {
    @Bindable var viewModel: PlayerViewModel
    @State private var backgroundColor: Color = .black
    @State private var isDragging = false
    @State private var shuffleOn = false
    @State private var repeatOn = false

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

        VStack(spacing: 0) {
            topBar

            Spacer(minLength: DesignTokens.Spacing.sm)

            albumArt
                .frame(maxWidth: DesignTokens.Layout.albumArtMaxSize, maxHeight: DesignTokens.Layout.albumArtMaxSize)

            Spacer(minLength: DesignTokens.Spacing.lg)

            trackInfo

            progressSection

            Spacer(minLength: DesignTokens.Spacing.lg)

            playbackControls

            bottomBar
        }
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }
        .task { await extractColor() }
    }

    // MARK: - Background

    private var background: some View {
            LinearGradient(
                colors: [backgroundColor, backgroundColor.opacity(DesignTokens.Opacity.tertiary), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .animation(DesignTokens.Animation.colorTransition, value: backgroundColor)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        let topInset = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 59

        return VStack(spacing: 0) {
            dragHandle
            HStack {
                artistAvatar
                Spacer()
                lyricsButton
                airPlayButton
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .padding(.top, topInset)
    }

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.white.opacity(DesignTokens.Opacity.tertiary))
            .frame(width: 40, height: 4)
            .padding(.top, DesignTokens.Spacing.sm)
            .padding(.bottom, DesignTokens.Spacing.lg)
    }

    private var artistAvatar: some View {
        ZStack {
            Color.white.opacity(DesignTokens.Opacity.ghost)
            Image(systemName: "person.fill")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
    }

    private var lyricsButton: some View {
        Button(action: {}) {
            Text("Lyrics")
                .font(DesignTokens.Typography.secondaryFont)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(DesignTokens.Opacity.primary))
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(.white.opacity(DesignTokens.Opacity.ghost))
                .clipShape(Capsule())
        }
    }

    private var airPlayButton: some View {
        Button(action: {}) {
            Image(systemName: "airplayaudio")
                .font(.body)
                .foregroundStyle(.white.opacity(DesignTokens.Opacity.primary))
                .frame(width: 36, height: 36)
                .background(.white.opacity(DesignTokens.Opacity.ghost))
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
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.artwork))
                .shadow(
                    color: DesignTokens.Shadow.md.color,
                    radius: DesignTokens.Shadow.md.radius,
                    y: DesignTokens.Shadow.md.y
                )
            } else {
                albumFallback
            }
        }
    }

    private var albumFallback: some View {
        ZStack {
            Color.white.opacity(DesignTokens.Opacity.ghost)
            Image(systemName: "music.note")
                .font(.system(size: DesignTokens.Layout.albumArtFallbackIcon))
                .foregroundStyle(.white.opacity(DesignTokens.Opacity.tertiary))
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.artwork))
    }

    // MARK: - Track Info

    private var trackInfo: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(viewModel.player.currentTrack?.title ?? "Not Playing")
                    .font(DesignTokens.Typography.titleFont)
                    .fontWeight(DesignTokens.Typography.titleWeight)
                    .foregroundStyle(.white.opacity(DesignTokens.Opacity.primary))
                    .lineLimit(1)

                Text(viewModel.player.currentTrack?.artist ?? "")
                    .font(DesignTokens.Typography.secondaryFont)
                    .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
                    .lineLimit(1)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
            }
        }
        .padding(.top, DesignTokens.Spacing.lg)
        .padding(.bottom, DesignTokens.Spacing.sm)
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let progress = viewModel.player.progress

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(DesignTokens.Opacity.tertiary))
                        .frame(height: DesignTokens.Layout.progressBarHeight)

                    Capsule()
                        .fill(.white.opacity(DesignTokens.Opacity.primary))
                        .frame(width: width * progress, height: DesignTokens.Layout.progressBarHeight)

                    Circle()
                        .fill(.white.opacity(DesignTokens.Opacity.primary))
                        .frame(width: DesignTokens.Layout.progressThumbSize, height: DesignTokens.Layout.progressThumbSize)
                        .offset(x: width * progress - DesignTokens.Layout.progressThumbSize / 2)
                }
                .frame(height: DesignTokens.Layout.progressThumbSize)
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
            .frame(height: DesignTokens.Layout.progressThumbSize)

            HStack {
                Text(formatTime(viewModel.player.currentTime))
                    .font(DesignTokens.Typography.timeFont)
                    .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
                    .monospacedDigit()
                Spacer()
                Text("-\(formatTime(viewModel.player.duration - viewModel.player.currentTime))")
                    .font(DesignTokens.Typography.timeFont)
                    .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
                    .monospacedDigit()
            }
        }
        .padding(.top, DesignTokens.Spacing.sm)
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        HStack(spacing: 0) {
            Button(action: { shuffleOn.toggle() }) {
                Image(systemName: "shuffle")
                    .font(.body)
                    .foregroundStyle(shuffleOn ? .white.opacity(DesignTokens.Opacity.primary) : .white.opacity(DesignTokens.Opacity.tertiary))
            }
            .frame(width: 50)

            Spacer()

            Button(action: { viewModel.player.skipToPrevious() }) {
                Image(systemName: "backward.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(DesignTokens.Opacity.primary))
            }
            .frame(width: 50)

            Spacer()

            Button(action: { viewModel.player.togglePlayback() }) {
                Image(systemName: viewModel.player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: DesignTokens.Layout.playButtonSize))
                    .foregroundStyle(.white.opacity(DesignTokens.Opacity.primary))
            }
            .frame(width: 70)

            Spacer()

            Button(action: { viewModel.player.skipToNext() }) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(DesignTokens.Opacity.primary))
            }
            .frame(width: 50)

            Spacer()

            Button(action: { repeatOn.toggle() }) {
                Image(systemName: "repeat")
                    .font(.body)
                    .foregroundStyle(repeatOn ? .white.opacity(DesignTokens.Opacity.primary) : .white.opacity(DesignTokens.Opacity.tertiary))
            }
            .frame(width: 50)
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button(action: {}) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "line.3.horizontal")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Playing from")
                            .font(DesignTokens.Typography.tertiaryFont)
                            .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
                        Text(viewModel.player.currentTrack?.album ?? "Library")
                            .font(DesignTokens.Typography.tertiaryFont)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(DesignTokens.Opacity.primary))
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            HStack(spacing: DesignTokens.Spacing.lg) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
                }
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundStyle(.white.opacity(DesignTokens.Opacity.secondary))
                }
            }
        }
        .padding(.top, DesignTokens.Spacing.lg)
        .padding(.bottom, DesignTokens.Spacing.lg)
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
