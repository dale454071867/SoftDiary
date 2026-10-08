import SwiftUI

/// Compact portrait mascot for cards/badges; reuses the full portrait view
struct MoodMascotView: View {
    let mood: Mood
    var size: CGFloat = 88
    var pose: CharacterPose = .idle
    var isAnimated: Bool = true

    var body: some View {
        CharacterPortraitView(
            mood: mood,
            pose: pose,
            height: size * 1.35,
            showPlatform: false,
            isAnimated: isAnimated
        )
        .frame(width: size * 1.15, height: size * 1.45)
    }
}

struct MoodPickerRow: View {
    @Binding var selection: Mood

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        withAnimation(AppTheme.bouncy) {
                            selection = mood
                        }
                    } label: {
                        VStack(spacing: 6) {
                            CharacterPortraitView(
                                mood: mood,
                                pose: mood.recommendedPose,
                                height: 96,
                                isAnimated: selection == mood
                            )
                            Text(mood.title)
                                .font(AppTheme.captionFont)
                                .foregroundStyle(selection == mood ? AppTheme.ink : AppTheme.inkSoft)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(selection == mood ? mood.softFill : Color.white.opacity(0.35))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
