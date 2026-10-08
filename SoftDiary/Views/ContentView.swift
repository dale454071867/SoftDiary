import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var lockStore: LockStore
    @ObservedObject private var themeStore = ThemeStore.shared
    @State private var showSplash = true

    var body: some View {
        ZStack {
            MainTabView()
                .opacity(showSplash ? 0 : 1)
                .allowsHitTesting(!showSplash && lockStore.isUnlocked)

            if showSplash {
                LaunchSplash {
                    withAnimation(AppTheme.gentle) {
                        showSplash = false
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    )
                )
                .zIndex(2)
            }

            if !showSplash && lockStore.isLockEnabled && lockStore.hasPIN && !lockStore.isUnlocked {
                LockScreenView()
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
        .id(themeStore.skin.id)
    }
}

private struct LaunchSplash: View {
    var onEnter: () -> Void

    @ObservedObject private var themeStore = ThemeStore.shared
    @State private var appear = false
    @State private var floatUp = false
    @State private var buttonPulse = false
    @State private var openedDocument: LegalDocument?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    themeStore.skin.skyTop,
                    themeStore.skin.lavender.opacity(0.45),
                    themeStore.skin.skyBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            FloatingDecorationsLite(floatUp: floatUp, skin: themeStore.skin)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 18) {
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 148, height: 148)
                        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                        .shadow(color: themeStore.skin.butter.opacity(0.55), radius: 16, y: 8)
                        .scaleEffect(appear ? 1 : 0.72)
                        .opacity(appear ? 1 : 0)
                        .offset(y: floatUp ? -8 : 4)

                    Text("SoftDiary")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 16)

                    Text("Collect every mood with portraits and doodles")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.inkSoft)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 12)
                }

                Spacer()

                VStack(spacing: 16) {
                    Button(action: onEnter) {
                        HStack(spacing: 10) {
                            Text("Enter Journal")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .foregroundStyle(AppTheme.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Capsule(style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [themeStore.skin.butter, themeStore.skin.accent.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(0.75), lineWidth: 1.5)
                        )
                        .shadow(color: themeStore.skin.butter.opacity(0.55), radius: buttonPulse ? 16 : 10, y: 6)
                        .scaleEffect(buttonPulse ? 1.02 : 1)
                    }
                    .buttonStyle(CartoonPressStyle())
                    .padding(.horizontal, 36)

                    agreementHint
                        .padding(.horizontal, 28)

                    Text("Tap to start today’s little note")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSoft.opacity(0.85))
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(item: $openedDocument) { document in
            AgreementDocumentView(document: document)
        }
        .onAppear {
            withAnimation(AppTheme.bouncy) {
                appear = true
            }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                floatUp = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                buttonPulse = true
            }
        }
    }

    private var agreementHint: some View {
        VStack(spacing: 6) {
            Text("By entering, you agree to the")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.inkSoft)

            HStack(spacing: 4) {
                Button {
                    openedDocument = .userAgreement
                } label: {
                    Text("Terms of Use")
                        .font(AppTheme.captionFont.weight(.semibold))
                        .foregroundStyle(themeStore.skin.accent)
                }
                .buttonStyle(.plain)

                Text("and")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)

                Button {
                    openedDocument = .privacyPolicy
                } label: {
                    Text("Privacy Policy")
                        .font(AppTheme.captionFont.weight(.semibold))
                        .foregroundStyle(themeStore.skin.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

private struct FloatingDecorationsLite: View {
    var floatUp: Bool
    var skin: AppSkin

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(skin.butter.opacity(0.45))
                    .frame(width: 120, height: 120)
                    .blur(radius: 2)
                    .position(x: geo.size.width * 0.82, y: geo.size.height * 0.14)
                    .offset(y: floatUp ? -10 : 6)

                Circle()
                    .fill(skin.mint.opacity(0.35))
                    .frame(width: 160, height: 160)
                    .blur(radius: 8)
                    .position(x: geo.size.width * 0.12, y: geo.size.height * 0.72)

                CloudBlob()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 130, height: 64)
                    .position(x: geo.size.width * 0.22, y: geo.size.height * 0.18)
                    .offset(x: floatUp ? 8 : -6)
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ContentView()
        .environmentObject(DiaryStore())
        .environmentObject(LockStore())
}
