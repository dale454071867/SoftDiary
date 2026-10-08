import SwiftUI

struct CalendarDiaryView: View {
    @EnvironmentObject private var store: DiaryStore
    var onOpen: (DiaryEntry) -> Void

    @State private var month = Date()
    @State private var selectedDay = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                header
                monthGrid
                dayPortraitBanner
                dayEntries
            }
            .padding(20)
            .padding(.bottom, TabBarLayout.contentBottomPadding)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button {
                withAnimation(AppTheme.gentle) {
                    month = calendar.date(byAdding: .month, value: -1, to: month) ?? month
                }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.inkSoft)
            }

            Spacer()
            Text(monthTitle)
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.ink)
            Spacer()

            Button {
                withAnimation(AppTheme.gentle) {
                    month = calendar.date(byAdding: .month, value: 1, to: month) ?? month
                }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.inkSoft)
            }
        }
    }

    private var monthGrid: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { w in
                    Text(w)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSoft)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { day in
                    dayCell(day)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppTheme.card)
            )
        }
    }

    private func dayCell(_ day: Date?) -> some View {
        Group {
            if let day {
                let entries = store.entries(on: day)
                let mood = entries.first?.mood
                let selected = calendar.isDate(day, inSameDayAs: selectedDay)

                Button {
                    withAnimation(AppTheme.softSpring) {
                        selectedDay = day
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text("\(calendar.component(.day, from: day))")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(selected ? AppTheme.ink : AppTheme.inkSoft)

                        if let mood {
                            Circle()
                                .fill(mood.accent)
                                .frame(width: 8, height: 8)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(selected ? (mood?.softFill ?? AppTheme.butter.opacity(0.5)) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(height: 40)
            }
        }
    }

    private var dayPortraitBanner: some View {
        let entries = store.entries(on: selectedDay)
        return HStack(spacing: 14) {
            if let first = entries.first {
                CharacterPortraitView(mood: first.mood, pose: first.pose, height: 130)
            } else {
                CharacterPortraitView(mood: .calm, pose: .idle, height: 130, isAnimated: true)
                    .opacity(0.75)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(dayTitle)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                Text(entries.isEmpty ? "No portrait journal for this day" : "\(entries.count) entries · tap a card")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.inkSoft)
                if let first = entries.first {
                    Text("Pose: \(first.pose.title) · \(first.mood.title)")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(first.mood.accent)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.6))
        )
    }

    private var dayEntries: some View {
        let entries = store.entries(on: selectedDay)
        return VStack(spacing: 12) {
            ForEach(entries) { entry in
                Button {
                    onOpen(entry)
                } label: {
                    DiaryCardView(entry: entry)
                }
                .buttonStyle(CartoonPressStyle())
            }
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }

    private var dayTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d · EEEE"
        return formatter.string(from: selectedDay)
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: first)
        var result: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: first) {
                result.append(date)
            }
        }
        return result
    }
}
