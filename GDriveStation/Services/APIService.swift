import Foundation

final class APIService {
    static let shared = APIService()
    private let baseURL = "https://music-proxyserver-gdrive.sakvragi.workers.dev"

    private init() {}

    func fetchTracks() async throws -> [Track] {
        try await fetch(path: "/api/track")
    }

    func fetchTrack(id: String) async throws -> Track {
        try await fetch(path: "/api/track/\(id)")
    }

    func fetchPlaylistIds() async throws -> [String] {
        try await fetch(path: "/api/playlist")
    }

    func fetchPlaylist(id: String) async throws -> Playlist {
        try await fetch(path: "/api/playlist/\(id)")
    }

    private func fetch<T: Decodable>(path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.httpError(statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case httpError(Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .httpError(let code): return "HTTP Error: \(code)"
        case .decodingError: return "Failed to decode response"
        }
    }
}
