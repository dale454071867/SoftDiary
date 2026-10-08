import SwiftUI

@main
struct SoftDiaryApp: App {
    @StateObject private var store = DiaryStore()
    @StateObject private var lockStore = LockStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(lockStore)
                .preferredColorScheme(.light)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background {
                        lockStore.lockIfNeeded()
                    }
                }
        }
    }
}
