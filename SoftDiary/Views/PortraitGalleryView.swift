import SwiftUI

struct PortraitGalleryView: View {
    var onWriteWith: (Mood, CharacterPose) -> Void

    @State private var mood: Mood = .sunny
    @State private var pose: CharacterPose = .cheer
    @State private var appear = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Portrait Gallery")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Journal art uses portraits — not photo-library images")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.inkSoft)
                    .frame(maxWidth: .infinity, alignment: .leading)

                stage
                MoodPortraitPicker(mood: $mood, pose: $pose)

                Button {
                    onWriteWith(mood, pose)
                } label: {
                    Label("Write with this portrait", systemImage: "pencil.line")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(mood.outfitColor))
                        .shadow(color: mood.accent.opacity(0.35), radius: 10, y: 5)
                }
                .buttonStyle(CartoonPressStyle())

                poseCatalog
            }
            .padding(20)
            .padding(.bottom, TabBarLayout.contentBottomPadding)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(AppTheme.softSpring) { appear = true }
        }
    }

    private var stage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [mood.softFill, Color.white.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 280)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                )

            CharacterPortraitView(mood: mood, pose: pose, height: 210)
                .scaleEffect(appear ? 1 : 0.8)
                .opacity(appear ? 1 : 0)

            VStack {
                Spacer()
                HStack {
                    Text(mood.title)
                        .font(AppTheme.captionFont)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.75)))
                    Text(pose.title)
                        .font(AppTheme.captionFont)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(mood.softFill))
                }
                .padding(.bottom, 14)
            }
            .frame(height: 280)
        }
        .shadow(color: mood.accent.opacity(0.2), radius: 16, y: 8)
        .animation(AppTheme.bouncy, value: mood)
        .animation(AppTheme.bouncy, value: pose)
    }

    private var poseCatalog: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pose catalog")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.ink)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(CharacterPose.allCases) { item in
                    Button {
                        withAnimation(AppTheme.bouncy) { pose = item }
                    } label: {
                        VStack(spacing: 8) {
                            CharacterPortraitView(
                                mood: mood,
                                pose: item,
                                height: 120,
                                isAnimated: pose == item
                            )
                            Text(item.title)
                                .font(AppTheme.headlineFont)
                                .foregroundStyle(AppTheme.ink)
                            Text(item.subtitle)
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.inkSoft)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(pose == item ? mood.softFill : AppTheme.card)
                        )
                    }
                    .buttonStyle(CartoonPressStyle())
                }
            }
        }
    }
}
