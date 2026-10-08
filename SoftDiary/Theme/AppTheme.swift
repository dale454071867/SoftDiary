import SwiftUI

enum AppTheme {
    private static var skin: AppSkin { ThemeStore.shared.skin }

    static var skyTop: Color { skin.skyTop }
    static var skyBottom: Color { skin.skyBottom }
    static var ink: Color { Color(hex: 0x3D3A4A) }
    static var inkSoft: Color { Color(hex: 0x6F6A7D) }
    static var card: Color { Color.white.opacity(0.88) }
    static var bubble: Color { skin.bubble }
    static var mint: Color { skin.mint }
    static var butter: Color { skin.butter }
    static var lavender: Color { skin.lavender }
    static var accent: Color { skin.accent }

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded).weight(.medium)

    static let softSpring = Animation.spring(response: 0.45, dampingFraction: 0.68)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.55)
    static let gentle = Animation.spring(response: 0.55, dampingFraction: 0.82)
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

struct CartoonBackground: View {
    @ObservedObject private var themeStore = ThemeStore.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [themeStore.skin.skyTop, themeStore.skin.skyBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            FloatingDecorations(skin: themeStore.skin)
        }
        .id(themeStore.skin.id)
    }
}

private struct FloatingDecorations: View {
    let skin: AppSkin
    @State private var drift = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                CloudBlob()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 140, height: 70)
                    .position(x: geo.size.width * 0.18, y: geo.size.height * 0.12)
                    .offset(x: drift ? 10 : -6)

                CloudBlob()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 100, height: 52)
                    .position(x: geo.size.width * 0.78, y: geo.size.height * 0.2)
                    .offset(x: drift ? -8 : 8)

                Circle()
                    .fill(skin.butter.opacity(0.55))
                    .frame(width: 90, height: 90)
                    .blur(radius: 2)
                    .position(x: geo.size.width * 0.86, y: geo.size.height * 0.08)
                    .scaleEffect(drift ? 1.05 : 0.95)

                Circle()
                    .fill(skin.lavender.opacity(0.35))
                    .frame(width: 160, height: 160)
                    .blur(radius: 8)
                    .position(x: geo.size.width * 0.1, y: geo.size.height * 0.78)

                Circle()
                    .fill(skin.mint.opacity(0.3))
                    .frame(width: 180, height: 180)
                    .blur(radius: 10)
                    .position(x: geo.size.width * 0.9, y: geo.size.height * 0.85)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true)) {
                    drift = true
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct CloudBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.addEllipse(in: CGRect(x: w * 0.08, y: h * 0.28, width: w * 0.42, height: h * 0.55))
        path.addEllipse(in: CGRect(x: w * 0.28, y: h * 0.08, width: w * 0.45, height: h * 0.62))
        path.addEllipse(in: CGRect(x: w * 0.52, y: h * 0.25, width: w * 0.4, height: h * 0.55))
        return path
    }
}
