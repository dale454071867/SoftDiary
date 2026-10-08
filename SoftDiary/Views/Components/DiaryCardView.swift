import SwiftUI

struct DiaryCardView: View {
    let entry: DiaryEntry
    var appearDelay: Double = 0

    @State private var appeared = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d · EEE"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 10) {
            CharacterPortraitView(
                mood: entry.mood,
                pose: entry.pose,
                height: 108,
                showPlatform: true,
                isAnimated: false
            )
            .frame(width: 92, height: 120)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(Self.dateFormatter.string(from: entry.date))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSoft)
                    Spacer()
                    if entry.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: 0xFF8A80))
                    }
                    Text(entry.mood.title)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(entry.mood.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(entry.mood.softFill))
                }

                Text(entry.displayTitle)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                Text(entry.previewText)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.inkSoft)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    ForEach(entry.tags.prefix(2)) { tag in
                        Text(tag.title)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.inkSoft)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.white.opacity(0.7)))
                    }
                    Text(entry.pose.title)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(entry.mood.accent)
                    if entry.hasPhotos {
                        Label("Pic", systemImage: "photo")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: 0x2E8B6A))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppTheme.mint.opacity(0.75)))
                    }
                    if entry.hasAudio {
                        Label("Audio", systemImage: "mic.fill")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: 0x7B5EA7))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppTheme.lavender.opacity(0.75)))
                    }
                    if entry.hasSketch {
                        Label("Draw", systemImage: "scribble.variable")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: 0xFF8A80))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color(hex: 0xFFCDD2).opacity(0.75)))
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.card)
                .shadow(color: entry.mood.accent.opacity(0.18), radius: 14, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 18)
        .onAppear {
            withAnimation(AppTheme.softSpring.delay(appearDelay)) {
                appeared = true
            }
        }
    }
}
