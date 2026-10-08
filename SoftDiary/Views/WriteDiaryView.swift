import PencilKit
import SwiftUI

struct WriteDiaryView: View {
    @EnvironmentObject private var store: DiaryStore
    @Environment(\.dismiss) private var dismiss

    var initialMood: Mood? = nil
    var initialPose: CharacterPose? = nil
    var editing: DiaryEntry? = nil

    @State private var mood: Mood = .sunny
    @State private var pose: CharacterPose = .idle
    @State private var title = ""
    @State private var content = ""
    @State private var date = Date()
    @State private var tags: [DiaryTag] = []
    @State private var prompt = ""
    @State private var drawing = PKDrawing()
    @State private var canvasIdentity = UUID()
    @State private var photoFileNames: [String] = []
    @State private var audioFileName: String?
    @State private var showBurst = false
    @State private var mascotPop = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case title, content
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !drawing.strokes.isEmpty
            || !photoFileNames.isEmpty
            || audioFileName != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CartoonBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        portraitPreview
                        promptCard
                        MoodPortraitPicker(mood: $mood, pose: $pose)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags (up to 3)")
                                .font(AppTheme.headlineFont)
                                .foregroundStyle(AppTheme.ink)
                            TagChipPicker(tags: $tags)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(AppTheme.card)
                        )

                        formCard

                        DiaryPhotoPickerSection(photoFileNames: $photoFileNames)
                        DiaryAudioRecorderSection(audioFileName: $audioFileName)

                        DiarySketchPad(drawing: $drawing)
                            .id(canvasIdentity)
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }

                if showBurst {
                    SaveSuccessBurst()
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle(editing == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.inkSoft)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(canSave ? mood.accent : AppTheme.inkSoft)
                        .disabled(!canSave)
                }
            }
        }
        .onAppear {
            if let editing {
                mood = editing.mood
                pose = editing.pose
                title = editing.title
                content = editing.content
                date = editing.date
                tags = editing.tags
                prompt = editing.prompt
                drawing = PKDrawing.fromSoftDiary(editing.sketchData)
                photoFileNames = editing.photoFileNames
                audioFileName = editing.audioFileName
                canvasIdentity = UUID()
            } else {
                if let initialMood { mood = initialMood }
                if let initialPose {
                    pose = initialPose
                } else {
                    pose = mood.recommendedPose
                }
                prompt = WritingPrompt.random()
            }
            withAnimation(AppTheme.bouncy) {
                mascotPop = true
            }
        }
    }

    private var portraitPreview: some View {
        VStack(spacing: 8) {
            CharacterPortraitView(mood: mood, pose: pose, height: 180)
                .scaleEffect(mascotPop ? 1 : 0.6)
                .opacity(mascotPop ? 1 : 0)

            Text("\(mood.title) · \(pose.title)")
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.ink)
                .animation(AppTheme.softSpring, value: mood)
                .animation(AppTheme.softSpring, value: pose)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(mood.softFill)
        )
    }

    private var promptCard: some View {
        HStack(alignment: .top, spacing: 10) {
            CharacterPortraitView(mood: .curious, pose: .wave, height: 56, showPlatform: false, isAnimated: false)
                .frame(width: 48, height: 60)

            VStack(alignment: .leading, spacing: 6) {
                Text("Writing prompt")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
                Text(prompt)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Button {
                withAnimation(AppTheme.softSpring) {
                    prompt = WritingPrompt.random()
                }
            } label: {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title3)
                    .foregroundStyle(mood.accent)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.65))
        )
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .font(AppTheme.bodyFont)
                .tint(mood.accent)

            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
                TextField("Give today a little name", text: $title)
                    .font(AppTheme.headlineFont)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white.opacity(0.75)))
                    .focused($focusedField, equals: .title)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Body")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
                TextEditor(text: $content)
                    .font(AppTheme.bodyFont)
                    .frame(minHeight: 150)
                    .padding(12)
                    .scrollContentBackground(.hidden)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white.opacity(0.75)))
                    .focused($focusedField, equals: .content)
                    .overlay(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Write something — photos and voice notes welcome~")
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.inkSoft.opacity(0.7))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.card)
                .shadow(color: mood.accent.opacity(0.15), radius: 16, y: 8)
        )
    }

    private func save() {
        focusedField = nil

        if let editing {
            let removedPhotos = Set(editing.photoFileNames).subtracting(photoFileNames)
            MediaStore.delete(fileNames: Array(removedPhotos))
            if let oldAudio = editing.audioFileName, oldAudio != audioFileName {
                MediaStore.delete(fileName: oldAudio)
            }
        }

        var entry = editing ?? DiaryEntry()
        entry.date = date
        entry.mood = mood
        entry.pose = pose
        entry.title = title
        entry.content = content
        entry.tags = tags
        entry.prompt = prompt
        entry.sketchData = drawing.softDiaryData
        entry.photoFileNames = photoFileNames
        entry.audioFileName = audioFileName
        if editing == nil {
            entry.createdAt = Date()
        }

        showBurst = true
        withAnimation(AppTheme.bouncy) {
            if editing != nil {
                store.update(entry)
            } else {
                store.add(entry)
            }
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 550_000_000)
            dismiss()
        }
    }
}
