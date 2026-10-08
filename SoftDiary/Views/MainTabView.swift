import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: DiaryStore
    @ObservedObject private var themeStore = ThemeStore.shared
    @State private var tab: AppTab = .home
    @State private var showWriter = false
    @State private var homeEntry: DiaryEntry?
    @State private var calendarEntry: DiaryEntry?
    @State private var pendingMood: Mood?
    @State private var pendingPose: CharacterPose?

    var body: some View {
        ZStack(alignment: .bottom) {
            CartoonBackground()
                .ignoresSafeArea()

            // Content fills the screen and extends under the floating tab bar
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.keyboard)

            // Floating tab bar overlays the content
            CartoonTabBar(selection: $tab)
                .padding(.bottom, 8)
        }
        .id(themeStore.skin.id)
        .sheet(isPresented: $showWriter) {
            WriteDiaryView(initialMood: pendingMood, initialPose: pendingPose)
                .environmentObject(store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .onDisappear {
                    pendingMood = nil
                    pendingPose = nil
                }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .home:
            NavigationStack {
                HomeView(
                    onWrite: { showWriter = true },
                    onOpen: { homeEntry = $0 }
                )
                .navigationDestination(item: $homeEntry) { entry in
                    DiaryDetailView(entryID: entry.id)
                }
            }
        case .calendar:
            NavigationStack {
                CalendarDiaryView(onOpen: { calendarEntry = $0 })
                    .navigationDestination(item: $calendarEntry) { entry in
                        DiaryDetailView(entryID: entry.id)
                    }
            }
        case .stats:
            NavigationStack {
                StatsView()
            }
        case .gallery:
            NavigationStack {
                PortraitGalleryView(onWriteWith: { mood, pose in
                    pendingMood = mood
                    pendingPose = pose
                    showWriter = true
                })
            }
        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }
}
