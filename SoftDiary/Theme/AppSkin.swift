import SwiftUI

enum AppSkin: String, CaseIterable, Identifiable {
    case sunny
    case sakura
    case mintFresh
    case grape
    case ocean
    case cocoa

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sunny: return "Sunny Cream"
        case .sakura: return "Sakura Candy"
        case .mintFresh: return "Mint Soda"
        case .grape: return "Grape Dream"
        case .ocean: return "Ocean Bubbles"
        case .cocoa: return "Cocoa Afternoon"
        }
    }

    var subtitle: String {
        switch self {
        case .sunny: return "Default warm palette"
        case .sakura: return "Soft pink vibes"
        case .mintFresh: return "Fresh green energy"
        case .grape: return "Lavender fantasy"
        case .ocean: return "Sky and sea blues"
        case .cocoa: return "Gentle coffee browns"
        }
    }

    var skyTop: Color {
        switch self {
        case .sunny: return Color(hex: 0xFFF7E8)
        case .sakura: return Color(hex: 0xFFE8F0)
        case .mintFresh: return Color(hex: 0xE8FFF6)
        case .grape: return Color(hex: 0xF3EBFF)
        case .ocean: return Color(hex: 0xE7F6FF)
        case .cocoa: return Color(hex: 0xFFF0E4)
        }
    }

    var skyBottom: Color {
        switch self {
        case .sunny: return Color(hex: 0xE8F6FF)
        case .sakura: return Color(hex: 0xFFE4EC)
        case .mintFresh: return Color(hex: 0xD9F5EE)
        case .grape: return Color(hex: 0xE8DCFF)
        case .ocean: return Color(hex: 0xD3EEFF)
        case .cocoa: return Color(hex: 0xF0E0D0)
        }
    }

    var butter: Color {
        switch self {
        case .sunny: return Color(hex: 0xFFE29A)
        case .sakura: return Color(hex: 0xFFB7C5)
        case .mintFresh: return Color(hex: 0x9BE7C4)
        case .grape: return Color(hex: 0xD2B4FF)
        case .ocean: return Color(hex: 0x8FD3FF)
        case .cocoa: return Color(hex: 0xE2B892)
        }
    }

    var mint: Color {
        switch self {
        case .sunny: return Color(hex: 0xB8F2E6)
        case .sakura: return Color(hex: 0xFFD1DC)
        case .mintFresh: return Color(hex: 0xB8F2E6)
        case .grape: return Color(hex: 0xCDB4FF)
        case .ocean: return Color(hex: 0xB8E4FF)
        case .cocoa: return Color(hex: 0xD9C2A9)
        }
    }

    var lavender: Color {
        switch self {
        case .sunny: return Color(hex: 0xE5D4FF)
        case .sakura: return Color(hex: 0xFFC2D1)
        case .mintFresh: return Color(hex: 0xC9F0E0)
        case .grape: return Color(hex: 0xE5D4FF)
        case .ocean: return Color(hex: 0xC5E7FF)
        case .cocoa: return Color(hex: 0xE8D5C4)
        }
    }

    var bubble: Color {
        switch self {
        case .sunny: return Color(hex: 0xFFE8F0)
        case .sakura: return Color(hex: 0xFFE0E9)
        case .mintFresh: return Color(hex: 0xE0FFF4)
        case .grape: return Color(hex: 0xF0E6FF)
        case .ocean: return Color(hex: 0xE0F4FF)
        case .cocoa: return Color(hex: 0xF7E8DA)
        }
    }

    var accent: Color {
        switch self {
        case .sunny: return Color(hex: 0xFFB347)
        case .sakura: return Color(hex: 0xFF8FAB)
        case .mintFresh: return Color(hex: 0x3DCF9A)
        case .grape: return Color(hex: 0xB388FF)
        case .ocean: return Color(hex: 0x4DB7FF)
        case .cocoa: return Color(hex: 0xC48A58)
        }
    }

    var previewColors: [Color] {
        [skyTop, butter, lavender, skyBottom]
    }
}

final class ThemeStore: ObservableObject {
    static let shared = ThemeStore()

    @Published var skin: AppSkin {
        didSet {
            UserDefaults.standard.set(skin.rawValue, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "soft_diary_app_skin"

    private init() {
        let raw = UserDefaults.standard.string(forKey: Self.storageKey) ?? AppSkin.sunny.rawValue
        skin = AppSkin(rawValue: raw) ?? .sunny
    }
}
