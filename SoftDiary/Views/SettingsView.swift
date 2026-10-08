import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: DiaryStore
    @EnvironmentObject private var lockStore: LockStore
    @ObservedObject private var themeStore = ThemeStore.shared

    @State private var showPINSetup = false
    @State private var showDisableLockConfirm = false
    @State private var shareItems: [Any] = []
    @State private var showShare = false
    @State private var openedDocument: LegalDocument?
    @State private var exportTip = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                header

                sectionCard(title: "Theme Skins") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(AppSkin.allCases) { skin in
                            Button {
                                withAnimation(AppTheme.softSpring) {
                                    themeStore.skin = skin
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 4) {
                                        ForEach(Array(skin.previewColors.enumerated()), id: \.offset) { _, color in
                                            Circle().fill(color).frame(width: 14, height: 14)
                                        }
                                        Spacer()
                                        if themeStore.skin == skin {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(skin.accent)
                                        }
                                    }
                                    Text(skin.title)
                                        .font(AppTheme.headlineFont)
                                        .foregroundStyle(AppTheme.ink)
                                    Text(skin.subtitle)
                                        .font(AppTheme.captionFont)
                                        .foregroundStyle(AppTheme.inkSoft)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(themeStore.skin == skin ? skin.butter.opacity(0.45) : Color.white.opacity(0.55))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(themeStore.skin == skin ? skin.accent.opacity(0.55) : Color.clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(CartoonPressStyle())
                        }
                    }
                }

                sectionCard(title: "Passcode Lock") {
                    Toggle(isOn: Binding(
                        get: { lockStore.isLockEnabled && lockStore.hasPIN },
                        set: { newValue in
                            if newValue {
                                showPINSetup = true
                            } else if lockStore.hasPIN {
                                showDisableLockConfirm = true
                            }
                        }
                    )) {
                        settingsLabel("Enable passcode", subtitle: "Require a passcode after leaving the app", icon: "lock.fill")
                    }
                    .tint(AppTheme.accent)

                    if lockStore.hasPIN {
                        Divider().opacity(0.3)

                        Button {
                            showPINSetup = true
                        } label: {
                            settingsLabel("Change passcode", subtitle: "Set a new 4-digit passcode", icon: "key.fill")
                        }
                        .buttonStyle(CartoonPressStyle())

                        if lockStore.canUseBiometrics {
                            Divider().opacity(0.3)
                            Toggle(isOn: $lockStore.biometricsEnabled) {
                                settingsLabel(
                                    "Unlock with \(lockStore.biometryLabel)",
                                    subtitle: "Open your journal more easily",
                                    icon: "faceid"
                                )
                            }
                            .tint(AppTheme.accent)
                        }
                    }
                }

                sectionCard(title: "Export") {
                    Button {
                        exportAll()
                    } label: {
                        settingsLabel(
                            "Export all entries",
                            subtitle: "Create a text file to share to Files or Notes",
                            icon: "square.and.arrow.up"
                        )
                    }
                    .buttonStyle(CartoonPressStyle())

                    if !exportTip.isEmpty {
                        Text(exportTip)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.inkSoft)
                    }
                }

                sectionCard(title: "About") {
                    Button { openedDocument = .userAgreement } label: {
                        settingsLabel("Terms of Use", subtitle: nil, icon: "doc.text")
                    }
                    .buttonStyle(CartoonPressStyle())

                    Divider().opacity(0.3)

                    Button { openedDocument = .privacyPolicy } label: {
                        settingsLabel("Privacy Policy", subtitle: nil, icon: "hand.raised.fill")
                    }
                    .buttonStyle(CartoonPressStyle())

                    Divider().opacity(0.3)

                    settingsLabel(
                        "SoftDiary",
                        subtitle: "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")",
                        icon: "heart.fill"
                    )
                }
            }
            .padding(20)
            .padding(.bottom, TabBarLayout.contentBottomPadding)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showPINSetup) {
            PINSetupView()
                .environmentObject(lockStore)
        }
        .confirmationDialog("Turn off passcode?", isPresented: $showDisableLockConfirm, titleVisibility: .visible) {
            Button("Turn off and clear passcode", role: .destructive) {
                lockStore.clearPIN()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: shareItems)
        }
        .sheet(item: $openedDocument) { document in
            AgreementDocumentView(document: document)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Settings")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text("Skins · Passcode · Export")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
            }
            Spacer()
            Image("BrandLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: AppTheme.butter.opacity(0.4), radius: 8, y: 4)
        }
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.ink)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(AppTheme.card)
        )
    }

    private func settingsLabel(_ title: String, subtitle: String?, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 32, height: 32)
                .background(Circle().fill(AppTheme.butter.opacity(0.55)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSoft)
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }

    private func exportAll() {
        let text = ExportService.plainText(for: store.sortedEntries)
        guard let url = ExportService.writeTempTextFile(text) else {
            exportTip = "Export failed. Please try again later."
            return
        }
        shareItems = [url]
        showShare = true
        exportTip = "Ready: \(store.entries.count) entries"
    }
}

enum TabBarLayout {
    /// Extra bottom inset so lists can scroll under the floating tab bar
    static let contentBottomPadding: CGFloat = 110
    /// Lift the write FAB so it clears the tab bar
    static let fabBottomPadding: CGFloat = 96
}
