import Foundation
import SwiftUI

struct Track: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let artist: String
    let album: String
    let duration: Double
    let mimeType: String
    let size: Int64
    let trackNumber: Int
    let discNumber: Int
    let year: Int?
    let genre: String?
    let coverUrl: String?
    let coverType: String?
    let dominantColor: String?
    let dominantColors: [String]

    var streamURL: URL {
        URL(string: "\(APIService.baseURL)/api/stream/\(id)")!
    }

    var coverImageURL: URL? {
        guard let coverUrl else { return nil }
        return URL(string: coverUrl)
    }

    var durationFormatted: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var dominantSwiftUIColor: Color {
        guard let hex = dominantColors.first else { return .gray }
        return Color(hex: hex)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

struct Playlist: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let trackIds: [String]
    let ownerId: String
    let isPublic: Bool
    let createdAt: String
    let updatedAt: String
    let tracks: [Track]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
