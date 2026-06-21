import AVFoundation
import Combine

@Observable
final class PlayerService {
    var currentTrack: Track?
    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    var isLoading = false
    var queue: [Track] = []
    var currentIndex = 0

    var progress: Double {
        duration > 0 ? currentTime / duration : 0
    }

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: AnyCancellable?
    private var didPlayToEndObserver: Any?

    func setup() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try session.setActive(true)
        } catch {
            print("AudioSession error: \(error)")
        }

        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil, queue: nil
        ) { [weak self] notification in
            guard let self,
                  let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

            switch type {
            case .began:
                self.pause()
            case .ended:
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        self.play()
                    }
                }
            @unknown default: break
            }
        }
    }

    func play(track: Track, in newQueue: [Track]? = nil, at index: Int = 0) {
        if let newQueue {
            queue = newQueue
            currentIndex = index
        }

        currentTrack = track
        isLoading = true

        let playerItem = AVPlayerItem(url: track.streamURL)
        let newPlayer = AVPlayer(playerItem: playerItem)

        statusObserver?.cancel()
        statusObserver = playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.duration = playerItem.duration.seconds.isNaN ? 0 : playerItem.duration.seconds
                    self.isLoading = false
                    newPlayer.play()
                    self.isPlaying = true
                case .failed:
                    self.isLoading = false
                default:
                    break
                }
            }

        if let timeObserver { newPlayer.removeTimeObserver(timeObserver) }

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            self.currentTime = time.seconds.isNaN ? 0 : time.seconds
        }

        if let didPlayToEndObserver {
            NotificationCenter.default.removeObserver(didPlayToEndObserver)
        }
        didPlayToEndObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.skipToNext()
        }

        player = newPlayer
    }

    func play() {
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func togglePlayback() {
        isPlaying ? pause() : play()
    }

    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func skipToNext() {
        guard currentIndex + 1 < queue.count else {
            pause()
            return
        }
        currentIndex += 1
        play(track: queue[currentIndex])
    }

    func skipToPrevious() {
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
        play(track: queue[currentIndex])
    }

    func cleanup() {
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        statusObserver?.cancel()
        if let didPlayToEndObserver {
            NotificationCenter.default.removeObserver(didPlayToEndObserver)
        }
        player = nil
    }
}
