import SwiftUI

struct DiaryDetailView: View {
    @EnvironmentObject private var store: DiaryStore
    @Environment(\.dismiss) private var dismiss

    let entryID: UUID

    @State private var appear = false
    @State private var showDeleteConfirm = false
    @State private var showEditor = false
    @State private var showExportOptions = false
    @State private var shareItems: [Any] = []
    @State private var showShare = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, yyyy · EEEE"
        return formatter
    }()

    private var entry: DiaryEntry? {
        store.entries.first(where: { $0.id == entryID })
    }

    var body: some View {
        ZStack {
            CartoonBackground()

            if let live = entry {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        CharacterPortraitView(mood: live.mood, pose: live.pose, height: 210)
                            .scaleEffect(appear ? 1 : 0.7)
                            .opacity(appear ? 1 : 0)

                        VStack(spacing: 8) {
                            Text(Self.dateFormatter.string(from: live.date))
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.inkSoft)

                            Text(live.displayTitle)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.ink)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 8) {
                                Text(live.mood.title)
                                    .chip(color: live.mood.softFill, textColor: live.mood.accent)
                                Text(live.pose.title)
                                    .chip(color: Color.white.opacity(0.7), textColor: AppTheme.inkSoft)
                                if live.hasPhotos {
                                    Text("Photos")
                                        .chip(color: AppTheme.mint.opacity(0.8), textColor: AppTheme.ink)
                                }
                                if live.hasAudio {
                                    Text("Audio")
                                        .chip(color: AppTheme.lavender.opacity(0.8), textColor: AppTheme.ink)
                                }
                                if live.hasSketch {
                                    Text("Sketch")
                                        .chip(color: AppTheme.butter.opacity(0.8), textColor: AppTheme.ink)
                                }
                                if live.isFavorite {
                                    Text("Favorite")
                                        .chip(color: Color(hex: 0xFFCDD2), textColor: Color(hex: 0xE57373))
                                }
                            }

                            if !live.tags.isEmpty {
                                HStack {
                                    ForEach(live.tags) { tag in
                                        Text(tag.title)
                                            .chip(color: AppTheme.lavender.opacity(0.55), textColor: AppTheme.inkSoft)
                                    }
                                }
                            }
                        }
                        .opacity(appear ? 1 : 0)

                        if !live.prompt.isEmpty {
                            HStack(alignment: .top, spacing: 10) {
                                CharacterPortraitView(mood: .curious, pose: .wave, height: 52, showPlatform: false, isAnimated: false)
                                    .frame(width: 44, height: 56)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Prompt from then")
                                        .font(AppTheme.captionFont)
                                        .foregroundStyle(AppTheme.inkSoft)
                                    Text(live.prompt)
                                        .font(AppTheme.headlineFont)
                                        .foregroundStyle(AppTheme.ink)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.white.opacity(0.55))
                            )
                            .padding(.horizontal, 22)
                        }

                        Text(live.previewText)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(22)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(AppTheme.card)
                                    .shadow(color: live.mood.accent.opacity(0.16), radius: 14, y: 8)
                            )
                            .padding(.horizontal, 22)
                            .opacity(appear ? 1 : 0)

                        if live.hasPhotos {
                            DiaryPhotoGallery(fileNames: live.photoFileNames)
                                .padding(.horizontal, 22)
                                .opacity(appear ? 1 : 0)
                        }

                        if let audio = live.audioFileName {
                            DiaryAudioDetailPlayer(fileName: audio)
                                .padding(.horizontal, 22)
                                .opacity(appear ? 1 : 0)
                        }

                        if live.hasSketch {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Hand sketch", systemImage: "paintbrush.pointed.fill")
                                    .font(AppTheme.headlineFont)
                                    .foregroundStyle(AppTheme.ink)
                                SketchPreviewImage(data: live.sketchData, cornerRadius: 26)
                            }
                            .padding(.horizontal, 22)
                            .opacity(appear ? 1 : 0)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, TabBarLayout.contentBottomPadding)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            showExportOptions = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(AppTheme.inkSoft)
                        }
                        Button {
                            store.toggleFavorite(live)
                        } label: {
                            Image(systemName: live.isFavorite ? "heart.fill" : "heart")
                                .foregroundStyle(live.isFavorite ? Color(hex: 0xFF8A80) : AppTheme.inkSoft)
                        }
                        Button {
                            showEditor = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundStyle(AppTheme.inkSoft)
                        }
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(AppTheme.inkSoft)
                        }
                    }
                }
                .confirmationDialog("Export this entry", isPresented: $showExportOptions, titleVisibility: .visible) {
                    Button("Export card image") {
                        if let image = ExportService.renderCardImage(for: live) {
                            shareItems = [image]
                            showShare = true
                        }
                    }
                    Button("Export text") {
                        let text = ExportService.plainText(for: live)
                        shareItems = [text]
                        showShare = true
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .sheet(isPresented: $showShare) {
                    ShareSheet(items: shareItems)
                }
                .confirmationDialog("Delete this entry?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        withAnimation(AppTheme.gentle) {
                            store.delete(live)
                        }
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .sheet(isPresented: $showEditor) {
                    WriteDiaryView(editing: live)
                        .environmentObject(store)
                        .presentationDetents([.large])
                        .presentationCornerRadius(32)
                }
            } else {
                VStack(spacing: 12) {
                    CharacterPortraitView(mood: .rainy, pose: .sit, height: 140)
                    Text("This entry is gone")
                        .font(AppTheme.headlineFont)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(AppTheme.softSpring) {
                appear = true
            }
        }
    }
}

private extension Text {
    func chip(color: Color, textColor: Color) -> some View {
        self
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(color))
    }
}
