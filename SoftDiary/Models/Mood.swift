import SwiftUI

enum Mood: String, CaseIterable, Identifiable, Codable {
    case sunny
    case calm
    case curious
    case sleepy
    case rainy
    case stormy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sunny: return "Happy"
        case .calm: return "Calm"
        case .curious: return "Curious"
        case .sleepy: return "Sleepy"
        case .rainy: return "Sad"
        case .stormy: return "Grumpy"
        }
    }

    var accent: Color {
        switch self {
        case .sunny: return Color(hex: 0xFFB347)
        case .calm: return Color(hex: 0x7EC8E3)
        case .curious: return Color(hex: 0xC9A0FF)
        case .sleepy: return Color(hex: 0xA8E6CF)
        case .rainy: return Color(hex: 0x9BB7D4)
        case .stormy: return Color(hex: 0xFF8A80)
        }
    }

    var softFill: Color {
        accent.opacity(0.22)
    }

    var cheekColor: Color {
        switch self {
        case .stormy: return Color(hex: 0xFFCDD2)
        default: return Color(hex: 0xFFB4A8)
        }
    }

    var hairColor: Color {
        switch self {
        case .sunny: return Color(hex: 0xF4A261)
        case .calm: return Color(hex: 0x6D8CAD)
        case .curious: return Color(hex: 0x9B7EBD)
        case .sleepy: return Color(hex: 0x7FB69E)
        case .rainy: return Color(hex: 0x7A8FA6)
        case .stormy: return Color(hex: 0xC97B84)
        }
    }

    var outfitColor: Color {
        switch self {
        case .sunny: return Color(hex: 0xFFD166)
        case .calm: return Color(hex: 0xA8D8EA)
        case .curious: return Color(hex: 0xD4B5FF)
        case .sleepy: return Color(hex: 0xB8E0D2)
        case .rainy: return Color(hex: 0xB0C4DE)
        case .stormy: return Color(hex: 0xFFABAB)
        }
    }

    var skinColor: Color {
        Color(hex: 0xFFE0C8)
    }

    var recommendedPose: CharacterPose {
        switch self {
        case .sunny: return .cheer
        case .calm: return .idle
        case .curious: return .wave
        case .sleepy: return .sleep
        case .rainy: return .sit
        case .stormy: return .shy
        }
    }
}
