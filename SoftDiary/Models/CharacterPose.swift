import Foundation

enum CharacterPose: String, CaseIterable, Identifiable, Codable {
    case idle
    case wave
    case cheer
    case shy
    case sit
    case sleep

    var id: String { rawValue }

    var title: String {
        switch self {
        case .idle: return "Idle"
        case .wave: return "Wave"
        case .cheer: return "Cheer"
        case .shy: return "Shy"
        case .sit: return "Sit"
        case .sleep: return "Sleep"
        }
    }

    var subtitle: String {
        switch self {
        case .idle: return "Quietly standing by"
        case .wave: return "Saying hello today"
        case .cheer: return "Celebrating good vibes"
        case .shy: return "Feeling a little shy"
        case .sit: return "Sitting down to chat"
        case .sleep: return "Taking a tiny nap"
        }
    }
}
