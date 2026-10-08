import SwiftUI

/// Pure SwiftUI character portrait (used instead of photo assets)
struct CharacterPortraitView: View {
    let mood: Mood
    var pose: CharacterPose = .idle
    var height: CGFloat = 220
    var showPlatform: Bool = true
    var isAnimated: Bool = true

    @State private var breathe = false
    @State private var blink = false
    @State private var sparkle = false

    private var scale: CGFloat { height / 220 }

    var body: some View {
        ZStack(alignment: .bottom) {
            if showPlatform {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [mood.accent.opacity(0.35), mood.accent.opacity(0.05)],
                            center: .center,
                            startRadius: 2,
                            endRadius: 70 * scale
                        )
                    )
                    .frame(width: 140 * scale, height: 28 * scale)
                    .offset(y: 6 * scale)
                    .scaleEffect(x: breathe ? 1.06 : 0.96)
            }

            character
                .frame(width: 160 * scale, height: height)
                .scaleEffect(breathe ? 1.02 : 1, anchor: .bottom)
                .offset(y: poseOffsetY)
                .rotationEffect(.degrees(poseRotation), anchor: .bottom)
        }
        .frame(width: 170 * scale, height: height + 16 * scale)
        .onAppear {
            guard isAnimated else { return }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                breathe = true
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                sparkle = true
            }
            startBlinkLoop()
        }
        .onChange(of: mood) { _, _ in
            bounceRefresh()
        }
        .onChange(of: pose) { _, _ in
            bounceRefresh()
        }
    }

    private var poseOffsetY: CGFloat {
        switch pose {
        case .cheer: return breathe ? -10 * scale : -2 * scale
        case .sleep: return 8 * scale
        case .sit: return 18 * scale
        default: return breathe ? -3 * scale : 0
        }
    }

    private var poseRotation: Double {
        switch pose {
        case .wave: return breathe ? 3 : -2
        case .shy: return breathe ? -4 : -2
        case .cheer: return breathe ? 4 : -4
        default: return breathe ? 1.2 : -1.2
        }
    }

    private var character: some View {
        ZStack {
            accessoryBack

            // Legs / lower body
            if pose != .sit && pose != .sleep {
                leg(x: -14, bent: pose == .cheer && breathe)
                leg(x: 14, bent: false)
            }

            // Body / dress
            dress
                .offset(y: pose == .sit || pose == .sleep ? 22 * scale : 28 * scale)

            // Arms
            arms

            // Head
            head
                .offset(y: pose == .sit || pose == .sleep ? -18 * scale : -36 * scale)

            accessoryFront
        }
    }

    // MARK: - Parts

    private var dress: some View {
        ZStack {
            // Torso
            RoundedRectangle(cornerRadius: 18 * scale, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [mood.outfitColor, mood.outfitColor.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 58 * scale, height: 54 * scale)
                .overlay(
                    Capsule()
                        .fill(Color.white.opacity(0.45))
                        .frame(width: 18 * scale, height: 8 * scale)
                        .offset(y: -12 * scale)
                )

            // Skirt
            Ellipse()
                .fill(mood.outfitColor.opacity(0.92))
                .frame(width: 86 * scale, height: 40 * scale)
                .offset(y: 28 * scale)
                .overlay(
                    Ellipse()
                        .stroke(Color.white.opacity(0.35), lineWidth: 2 * scale)
                        .frame(width: 86 * scale, height: 40 * scale)
                        .offset(y: 28 * scale)
                )

            if pose == .sit || pose == .sleep {
                // Sitting legs as rounded blob
                Capsule()
                    .fill(mood.outfitColor.opacity(0.85))
                    .frame(width: 70 * scale, height: 22 * scale)
                    .offset(y: 42 * scale)
                HStack(spacing: 28 * scale) {
                    shoe
                    shoe
                }
                .offset(y: 52 * scale)
            }
        }
        .shadow(color: mood.accent.opacity(0.2), radius: 8 * scale, y: 4 * scale)
    }

    private func leg(x: CGFloat, bent: Bool) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(mood.skinColor)
                .frame(width: 14 * scale, height: bent ? 28 * scale : 36 * scale)
            shoe
        }
        .offset(x: x * scale, y: 70 * scale)
        .rotationEffect(.degrees(bent ? -12 : 0), anchor: .top)
    }

    private var shoe: some View {
        Capsule()
            .fill(mood.hairColor.opacity(0.85))
            .frame(width: 18 * scale, height: 10 * scale)
    }

    private var arms: some View {
        ZStack {
            arm(side: -1)
            arm(side: 1)
        }
        .offset(y: pose == .sit || pose == .sleep ? 10 * scale : 8 * scale)
    }

    private func arm(side: CGFloat) -> some View {
        let baseX = side * 34 * scale
        let lift: Double = {
            switch pose {
            case .wave where side > 0: return breathe ? -55 : -35
            case .cheer: return breathe ? -70 : -50
            case .shy where side < 0: return 25
            case .sleep: return 40
            default: return breathe ? 8 : -4
            }
        }()

        return Capsule()
            .fill(mood.skinColor)
            .frame(width: 12 * scale, height: 36 * scale)
            .overlay(alignment: .bottom) {
                Circle()
                    .fill(mood.skinColor)
                    .frame(width: 14 * scale, height: 14 * scale)
                    .offset(y: 2 * scale)
            }
            .offset(x: baseX, y: 8 * scale)
            .rotationEffect(.degrees(lift * Double(side == 0 ? 1 : side)), anchor: .top)
    }

    private var head: some View {
        ZStack {
            // Hair back
            Ellipse()
                .fill(mood.hairColor)
                .frame(width: 78 * scale, height: 72 * scale)
                .offset(y: 4 * scale)

            // Side hair
            Ellipse()
                .fill(mood.hairColor.opacity(0.95))
                .frame(width: 22 * scale, height: 48 * scale)
                .offset(x: -34 * scale, y: 18 * scale)
            Ellipse()
                .fill(mood.hairColor.opacity(0.95))
                .frame(width: 22 * scale, height: 48 * scale)
                .offset(x: 34 * scale, y: 18 * scale)

            // Face
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white, mood.skinColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 64 * scale, height: 64 * scale)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 2 * scale)
                )
                .shadow(color: mood.accent.opacity(0.15), radius: 4 * scale, y: 2 * scale)

            // Bangs
            Capsule()
                .fill(mood.hairColor)
                .frame(width: 58 * scale, height: 22 * scale)
                .offset(y: -22 * scale)
            Circle()
                .fill(mood.hairColor)
                .frame(width: 20 * scale, height: 20 * scale)
                .offset(x: -16 * scale, y: -18 * scale)
            Circle()
                .fill(mood.hairColor)
                .frame(width: 20 * scale, height: 20 * scale)
                .offset(x: 16 * scale, y: -18 * scale)

            faceDetails
        }
    }

    private var faceDetails: some View {
        ZStack {
            // Cheeks
            Circle()
                .fill(mood.cheekColor.opacity(0.9))
                .frame(width: 10 * scale, height: 7 * scale)
                .offset(x: -16 * scale, y: 8 * scale)
            Circle()
                .fill(mood.cheekColor.opacity(0.9))
                .frame(width: 10 * scale, height: 7 * scale)
                .offset(x: 16 * scale, y: 8 * scale)

            // Eyes
            HStack(spacing: 14 * scale) {
                eyeView
                eyeView
            }
            .offset(y: -2 * scale)

            // Mouth
            mouthShape
                .stroke(Color(hex: 0xE89B9B), style: StrokeStyle(lineWidth: 2.2 * scale, lineCap: .round))
                .frame(width: 16 * scale, height: 8 * scale)
                .offset(y: 14 * scale)

            if mood == .curious {
                Text("?")
                    .font(.system(size: 14 * scale, weight: .black, design: .rounded))
                    .foregroundStyle(mood.accent)
                    .offset(x: 40 * scale, y: -40 * scale)
                    .opacity(sparkle ? 1 : 0.5)
            }
        }
    }

    private var eyeView: some View {
        Group {
            if pose == .sleep || mood == .sleepy {
                Capsule()
                    .fill(Color(hex: 0x5C5470))
                    .frame(width: 10 * scale, height: 2.2 * scale)
            } else if mood == .rainy {
                Capsule()
                    .fill(Color(hex: 0x5C5470))
                    .frame(width: 2.5 * scale, height: 9 * scale)
                    .rotationEffect(.degrees(16))
            } else {
                ZStack {
                    Capsule()
                        .fill(Color(hex: 0x5C5470))
                        .frame(width: 7 * scale, height: blink ? 1.5 * scale : 11 * scale)
                    if !blink {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 2.5 * scale, height: 2.5 * scale)
                            .offset(x: 1.2 * scale, y: -2 * scale)
                    }
                }
            }
        }
    }

    private var mouthShape: Path {
        Path { path in
            switch mood {
            case .sunny, .curious:
                path.move(to: CGPoint(x: 0, y: 2))
                path.addQuadCurve(to: CGPoint(x: 20, y: 2), control: CGPoint(x: 10, y: 12))
            case .calm:
                path.move(to: CGPoint(x: 3, y: 5))
                path.addQuadCurve(to: CGPoint(x: 17, y: 5), control: CGPoint(x: 10, y: 8))
            case .sleepy:
                path.move(to: CGPoint(x: 4, y: 6))
                path.addQuadCurve(to: CGPoint(x: 16, y: 6), control: CGPoint(x: 10, y: 2))
            case .rainy:
                path.move(to: CGPoint(x: 2, y: 8))
                path.addQuadCurve(to: CGPoint(x: 18, y: 8), control: CGPoint(x: 10, y: 1))
            case .stormy:
                path.move(to: CGPoint(x: 4, y: 6))
                path.addLine(to: CGPoint(x: 16, y: 6))
            }
        }
    }

    @ViewBuilder
    private var accessoryBack: some View {
        switch mood {
        case .sunny:
            Image(systemName: "sun.max.fill")
                .font(.system(size: 22 * scale))
                .foregroundStyle(Color(hex: 0xFFE082))
                .offset(x: 55 * scale, y: -70 * scale)
                .rotationEffect(.degrees(sparkle ? 12 : -8))
                .opacity(0.9)
        case .rainy:
            Image(systemName: "cloud.rain.fill")
                .font(.system(size: 24 * scale))
                .foregroundStyle(Color.white.opacity(0.85))
                .offset(y: -90 * scale)
                .scaleEffect(sparkle ? 1.05 : 0.95)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var accessoryFront: some View {
        switch pose {
        case .sleep:
            Text("zzz")
                .font(.system(size: 16 * scale, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.9))
                .offset(x: 48 * scale, y: -70 * scale)
                .opacity(sparkle ? 1 : 0.45)
        case .cheer:
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill([AppTheme.butter, AppTheme.mint, AppTheme.lavender][i])
                    .frame(width: 8 * scale, height: 8 * scale)
                    .offset(
                        x: CGFloat([-40, 0, 40][i]) * scale,
                        y: (sparkle ? -95 : -80) * scale
                    )
                    .opacity(sparkle ? 1 : 0.4)
            }
        case .shy:
            // Hands covering cheeks illusion already via arm pose
            EmptyView()
        default:
            EmptyView()
        }

        if mood == .stormy {
            Image(systemName: "bolt.fill")
                .font(.system(size: 14 * scale, weight: .bold))
                .foregroundStyle(Color(hex: 0xFFF59D))
                .offset(x: 48 * scale, y: -78 * scale)
                .opacity(sparkle ? 1 : 0.55)
        }
    }

    private func bounceRefresh() {
        breathe = false
        withAnimation(AppTheme.bouncy) {
            breathe = true
        }
    }

    private func startBlinkLoop() {
        Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64.random(in: 2_200_000_000...4_000_000_000))
                guard isAnimated, pose != .sleep, mood != .sleepy, mood != .rainy else { continue }
                withAnimation(.easeInOut(duration: 0.07)) { blink = true }
                try? await Task.sleep(nanoseconds: 90_000_000)
                withAnimation(.easeInOut(duration: 0.07)) { blink = false }
            }
        }
    }
}

// MARK: - Pickers

struct MoodPortraitPicker: View {
    @Binding var mood: Mood
    @Binding var pose: CharacterPose

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Portrait")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Mood.allCases) { item in
                        Button {
                            withAnimation(AppTheme.bouncy) {
                                mood = item
                                pose = item.recommendedPose
                            }
                        } label: {
                            VStack(spacing: 6) {
                                CharacterPortraitView(
                                    mood: item,
                                    pose: item == mood ? pose : item.recommendedPose,
                                    height: 110,
                                    isAnimated: item == mood
                                )
                                Text(item.title)
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(item == mood ? AppTheme.ink : AppTheme.inkSoft)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(item == mood ? item.softFill : Color.white.opacity(0.4))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(item == mood ? item.accent.opacity(0.6) : .clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }

            Text("Pose")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(CharacterPose.allCases) { item in
                        Button {
                            withAnimation(AppTheme.bouncy) {
                                pose = item
                            }
                        } label: {
                            Text(item.title)
                                .font(AppTheme.captionFont)
                                .foregroundStyle(pose == item ? AppTheme.ink : AppTheme.inkSoft)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule().fill(pose == item ? mood.softFill : Color.white.opacity(0.45))
                                )
                                .overlay(
                                    Capsule().stroke(pose == item ? mood.accent.opacity(0.55) : .clear, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct TagChipPicker: View {
    @Binding var tags: [DiaryTag]

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(DiaryTag.allCases) { tag in
                let selected = tags.contains(tag)
                Button {
                    withAnimation(AppTheme.softSpring) {
                        if selected {
                            tags.removeAll { $0 == tag }
                        } else if tags.count < 3 {
                            tags.append(tag)
                        }
                    }
                } label: {
                    Text(tag.title)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(selected ? AppTheme.ink : AppTheme.inkSoft)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(selected ? AppTheme.lavender.opacity(0.7) : Color.white.opacity(0.5)))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
