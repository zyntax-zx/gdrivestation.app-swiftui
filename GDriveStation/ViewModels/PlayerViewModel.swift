import SwiftUI

@Observable
final class PlayerViewModel {
    let player = PlayerService()
    let api = APIService.shared

    var tracks: [Track] = []
    var playlistIds: [String] = []
    var currentPlaylist: Playlist?
    var isLoading = false
    var isRefreshing = false
    var errorMessage: String?

    func loadLibrary() async {
        isLoading = true
        defer { isLoading = false }
        do {
            tracks = try await api.fetchTracks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadPlaylistIds() async {
        do {
            playlistIds = try await api.fetchPlaylistIds()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadPlaylist(id: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            currentPlaylist = try await api.fetchPlaylist(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            tracks = try await api.fetchTracks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func playTrack(_ track: Track) {
        let trackList = currentPlaylist?.tracks ?? tracks
        guard let index = trackList.firstIndex(where: { $0.id == track.id }) else {
            player.play(track: track)
            return
        }
        player.play(track: track, in: trackList, at: index)
    }

    func playAll() {
        guard let first = tracks.first else { return }
        player.play(track: first, in: tracks, at: 0)
    }
}
