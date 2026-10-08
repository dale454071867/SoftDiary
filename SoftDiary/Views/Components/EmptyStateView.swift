import SwiftUI

struct EmptyStateView: View {
    var onWrite: () -> Void

    @State private var wave = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppTheme.bubble)
                    .frame(width: 190, height: 190)
                    .scaleEffect(wave ? 1.06 : 0.96)

                CharacterPortraitView(mood: .curious, pose: .wave, height: 170)
            }

            Text("No entries yet")
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.ink)

            Text("Pick a portrait pose and write today’s mood")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.inkSoft)
                .multilineTextAlignment(.center)

            Button(action: onWrite) {
                Label("Start your first", systemImage: "pencil.and.outline")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(AppTheme.butter))
                    .shadow(color: AppTheme.butter.opacity(0.5), radius: 10, y: 5)
            }
            .buttonStyle(CartoonPressStyle())
            .padding(.top, 4)
        }
        .padding(28)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                wave = true
            }
        }
    }
}

struct CartoonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(AppTheme.softSpring, value: configuration.isPressed)
    }
}

struct SaveSuccessBurst: View {
    @State private var expand = false

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(burstColor(index))
                    .frame(width: 10, height: 10)
                    .offset(y: expand ? -70 : 0)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(expand ? 0 : 1)
                    .scaleEffect(expand ? 1.4 : 0.4)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                expand = true
            }
        }
    }

    private func burstColor(_ index: Int) -> Color {
        let colors = [AppTheme.butter, AppTheme.mint, AppTheme.lavender, Color(hex: 0xFFB4A8)]
        return colors[index % colors.count]
    }
}
