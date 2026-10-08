import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: DiaryStore
    var onWrite: () -> Void
    var onOpen: (DiaryEntry) -> Void

    @State private var query = ""
    @State private var filterMood: Mood?
    @State private var filterTag: DiaryTag?
    @State private var favoritesOnly = false
    @State private var fabPulse = false
    @State private var showFilters = false

    private var filtered: [DiaryEntry] {
        store.filtered(
            query: query,
            mood: filterMood,
            tag: filterTag,
            favoritesOnly: favoritesOnly
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 8)

            writeEntryCard
                .padding(.horizontal, 22)
                .padding(.bottom, 10)

            searchBar
                .padding(.horizontal, 22)
                .padding(.bottom, 8)

            if showFilters {
                filterBar
                    .padding(.horizontal, 22)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            if filtered.isEmpty {
                Spacer()
                if store.entries.isEmpty {
                    EmptyStateView(onWrite: onWrite)
                } else {
                    VStack(spacing: 12) {
                        CharacterPortraitView(mood: .sleepy, pose: .sit, height: 140)
                        Text("No matching entries")
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(AppTheme.ink)
                        Text("Try another keyword or filter")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.inkSoft)
                    }
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        streakBanner
                            .padding(.horizontal, 22)

                        ForEach(Array(filtered.enumerated()), id: \.element.id) { index, entry in
                            Button {
                                onOpen(entry)
                            } label: {
                                DiaryCardView(entry: entry, appearDelay: Double(min(index, 6)) * 0.05)
                            }
                            .buttonStyle(CartoonPressStyle())
                            .padding(.horizontal, 22)
                            .contextMenu {
                                Button {
                                    store.toggleFavorite(entry)
                                } label: {
                                    Label(entry.isFavorite ? "Unfavorite" : "Favorite", systemImage: entry.isFavorite ? "heart.slash" : "heart")
                                }
                                Button(role: .destructive) {
                                    withAnimation(AppTheme.gentle) {
                                        store.delete(entry)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.bottom, TabBarLayout.contentBottomPadding + 56)
                    .padding(.top, 4)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            writeFAB
                .padding(.trailing, 22)
                .padding(.bottom, TabBarLayout.fabBottomPadding)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
                Text("SoftDiary")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
            }

            Spacer()

            Button(action: onWrite) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 14, weight: .bold))
                    Text("Write")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(AppTheme.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(AppTheme.butter)
                )
                .shadow(color: AppTheme.butter.opacity(0.45), radius: 8, y: 4)
            }
            .buttonStyle(CartoonPressStyle())
        }
    }

    private var writeEntryCard: some View {
        Button(action: onWrite) {
            HStack(spacing: 12) {
                CharacterPortraitView(
                    mood: latest?.mood ?? .sunny,
                    pose: .wave,
                    height: 72,
                    showPlatform: false,
                    isAnimated: true
                )
                .frame(width: 64, height: 80)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Write a new entry")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.ink)
                    Text("Portrait · Photos · Audio · Sketch")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSoft)
                }

                Spacer(minLength: 0)

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: 0xFFB347))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.butter.opacity(0.75), AppTheme.lavender.opacity(0.45)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
            )
            .shadow(color: AppTheme.butter.opacity(0.3), radius: 10, y: 5)
        }
        .buttonStyle(CartoonPressStyle())
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.inkSoft)
            TextField("Search title or content", text: $query)
                .font(AppTheme.bodyFont)
            Button {
                withAnimation(AppTheme.softSpring) {
                    showFilters.toggle()
                }
            } label: {
                Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .foregroundStyle(AppTheme.inkSoft)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.72))
        )
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("All moods", active: filterMood == nil) { filterMood = nil }
                    ForEach(Mood.allCases) { mood in
                        filterChip(mood.title, active: filterMood == mood) { filterMood = mood }
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("All tags", active: filterTag == nil) { filterTag = nil }
                    ForEach(DiaryTag.allCases) { tag in
                        filterChip(tag.title, active: filterTag == tag) { filterTag = tag }
                    }
                    filterChip(favoritesOnly ? "Favorites ✓" : "Favorites", active: favoritesOnly) {
                        favoritesOnly.toggle()
                    }
                }
            }
        }
    }

    private func filterChip(_ title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(active ? AppTheme.ink : AppTheme.inkSoft)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(active ? AppTheme.butter : Color.white.opacity(0.5)))
        }
        .buttonStyle(.plain)
    }

    private var streakBanner: some View {
        HStack(spacing: 12) {
            CharacterPortraitView(mood: .sunny, pose: .cheer, height: 64, showPlatform: false, isAnimated: true)
                .frame(width: 56, height: 70)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(store.currentStreak)-day streak · \(store.entries.count) entries")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                Text("Every entry gets its own portrait")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
    }

    private var writeFAB: some View {
        Button(action: onWrite) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("Write")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                Capsule().fill(AppTheme.butter)
            )
            .shadow(color: AppTheme.butter.opacity(0.55), radius: fabPulse ? 14 : 8, y: 6)
            .scaleEffect(fabPulse ? 1.03 : 1)
        }
        .buttonStyle(CartoonPressStyle())
        .accessibilityLabel("Write entry")
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                fabPulse = true
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11: return "Good morning, sunshine"
        case 11..<14: return "Good afternoon — take it easy"
        case 14..<18: return "Good afternoon"
        case 18..<22: return "Good evening — settle in"
        default: return "Late night — go gently"
        }
    }

    private var latest: DiaryEntry? {
        store.sortedEntries.first
    }
}
