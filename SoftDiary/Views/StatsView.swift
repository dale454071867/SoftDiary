import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: DiaryStore

    private var topMood: Mood {
        store.moodCounts().max(by: { $0.1 < $1.1 })?.0 ?? .sunny
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Mood Stats")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)

                heroCard
                streakRow
                moodBars
                favoriteSection
            }
            .padding(20)
            .padding(.bottom, TabBarLayout.contentBottomPadding)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var heroCard: some View {
        HStack(spacing: 12) {
            CharacterPortraitView(
                mood: topMood,
                pose: topMood.recommendedPose,
                height: 160
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Most often lately")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
                Text(topMood.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text("\(store.entries.count) entries written")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.inkSoft)
                Text("\(store.favoriteEntries.count) favorites")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(topMood.accent)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.card)
                .shadow(color: topMood.accent.opacity(0.18), radius: 12, y: 6)
        )
    }

    private var streakRow: some View {
        HStack(spacing: 12) {
            CharacterPortraitView(mood: .sunny, pose: .cheer, height: 90, isAnimated: true)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(store.currentStreak)-day streak")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                Text(store.currentStreak > 0 ? "Your portrait is cheering you on!" : "Write today to start a streak")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.mint.opacity(0.45))
        )
    }

    private var moodBars: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood distribution")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.ink)

            let counts = store.moodCounts()
            let maxValue = max(counts.map(\.1).max() ?? 1, 1)

            ForEach(counts, id: \.0) { mood, count in
                HStack(spacing: 10) {
                    CharacterPortraitView(
                        mood: mood,
                        pose: mood.recommendedPose,
                        height: 48,
                        showPlatform: false,
                        isAnimated: false
                    )
                    .frame(width: 40, height: 52)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(mood.title)
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.ink)
                            Spacer()
                            Text("\(count)")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.inkSoft)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.55))
                                Capsule()
                                    .fill(mood.accent)
                                    .frame(width: geo.size.width * CGFloat(count) / CGFloat(maxValue))
                            }
                        }
                        .frame(height: 10)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.card)
        )
    }

    @ViewBuilder
    private var favoriteSection: some View {
        if !store.favoriteEntries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Favorite portrait journals")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(store.favoriteEntries.prefix(8)) { entry in
                            VStack(spacing: 8) {
                                CharacterPortraitView(
                                    mood: entry.mood,
                                    pose: entry.pose,
                                    height: 120,
                                    isAnimated: false
                                )
                                Text(entry.displayTitle)
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.ink)
                                    .lineLimit(1)
                                    .frame(width: 100)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(entry.mood.softFill)
                            )
                        }
                    }
                }
            }
        }
    }
}
