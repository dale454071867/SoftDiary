import SwiftUI

enum AppTab: Hashable, CaseIterable, Identifiable {
    case home, calendar, stats, gallery, settings

    var id: Self { self }

    var title: String {
        switch self {
        case .home: return "Journal"
        case .calendar: return "Calendar"
        case .stats: return "Moods"
        case .gallery: return "Poses"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "book.fill"
        case .calendar: return "calendar"
        case .stats: return "heart.fill"
        case .gallery: return "face.smiling.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var tint: Color {
        switch self {
        case .home: return Color(hex: 0xFFB347)
        case .calendar: return Color(hex: 0x7EC8E3)
        case .stats: return Color(hex: 0xFF8A80)
        case .gallery: return Color(hex: 0xC9A0FF)
        case .settings: return Color(hex: 0xA0A8B8)
        }
    }

    var soft: Color {
        tint.opacity(0.22)
    }
}

struct CartoonTabBar: View {
    @Binding var selection: AppTab
    @ObservedObject private var themeStore = ThemeStore.shared

    var body: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases) { tab in
                CartoonTabItem(
                    tab: tab,
                    isSelected: selection == tab
                ) {
                    withAnimation(AppTheme.bouncy) {
                        selection = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.92),
                                    themeStore.skin.skyBottom.opacity(0.88)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.95),
                                    themeStore.skin.lavender.opacity(0.55)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: themeStore.skin.lavender.opacity(0.22), radius: 18, y: 8)
                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .padding(.bottom, 2)
        .id(themeStore.skin.id)
    }
}

private struct CartoonTabItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    @State private var bounce = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(tab.soft)
                            .frame(width: 48, height: 30)
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(tab.tint.opacity(0.45), lineWidth: 1.2)
                            )
                            .scaleEffect(bounce ? 1.05 : 1)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 15 : 14, weight: .bold))
                        .foregroundStyle(isSelected ? tab.tint : AppTheme.inkSoft.opacity(0.75))
                        .offset(y: isSelected && bounce ? -1 : 0)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(height: 30)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundStyle(isSelected ? AppTheme.ink : AppTheme.inkSoft.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Circle()
                    .fill(isSelected ? tab.tint : Color.clear)
                    .frame(width: 4, height: 4)
                    .scaleEffect(isSelected ? 1 : 0.2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(CartoonPressStyle())
        .onChange(of: isSelected) { _, selected in
            guard selected else { return }
            bounce = false
            withAnimation(AppTheme.bouncy) {
                bounce = true
            }
        }
        .onAppear {
            if isSelected { bounce = true }
        }
    }
}
