import Foundation

enum DiaryTag: String, CaseIterable, Identifiable, Codable {
    case life
    case study
    case work
    case love
    case travel
    case dream
    case food
    case random

    var id: String { rawValue }

    var title: String {
        switch self {
        case .life: return "Life"
        case .study: return "Study"
        case .work: return "Work"
        case .love: return "Crush"
        case .travel: return "Out"
        case .dream: return "Dream"
        case .food: return "Food"
        case .random: return "Notes"
        }
    }
}

enum WritingPrompt {
    static let all: [String] = [
        "What moment do you want to keep today?",
        "If your mood were weather, what would it be?",
        "Say something kind to yourself.",
        "Did any tiny luck find you today?",
        "Which song matches how you feel now?",
        "A note for tomorrow’s you: remember…",
        "Something that made you laugh today.",
        "Who or what are you thankful for today?"
    ]

    static func random() -> String {
        all.randomElement() ?? all[0]
    }
}
