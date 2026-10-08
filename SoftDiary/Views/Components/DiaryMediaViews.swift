import PhotosUI
import SwiftUI
import UIKit

// MARK: - Photo attachment editor

struct DiaryPhotoPickerSection: View {
    @Binding var photoFileNames: [String]
    var maxCount: Int = 6

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showSourceMenu = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Photos", systemImage: "photo.on.rectangle.angled")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text("\(photoFileNames.count)/\(maxCount)")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
            }

            if !photoFileNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(photoFileNames, id: \.self) { name in
                            ZStack(alignment: .topTrailing) {
                                if let image = MediaStore.loadImage(fileName: name) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 96, height: 96)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                } else {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(AppTheme.lavender.opacity(0.4))
                                        .frame(width: 96, height: 96)
                                }

                                Button {
                                    withAnimation(AppTheme.softSpring) {
                                        MediaStore.delete(fileName: name)
                                        photoFileNames.removeAll { $0 == name }
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.white, Color(hex: 0xFF8A80))
                                        .shadow(radius: 2)
                                }
                                .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                PhotosPicker(
                    selection: $pickerItems,
                    maxSelectionCount: max(maxCount - photoFileNames.count, 0),
                    matching: .images
                ) {
                    mediaActionLabel(title: "Library", icon: "photo.on.rectangle")
                }
                .disabled(photoFileNames.count >= maxCount)

                Button {
                    showCamera = true
                } label: {
                    mediaActionLabel(title: "Camera", icon: "camera.fill")
                }
                .disabled(photoFileNames.count >= maxCount || !UIImagePickerController.isSourceTypeAvailable(.camera))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.card)
        )
        .onChange(of: pickerItems) { _, items in
            Task { await importPickerItems(items) }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                if let name = MediaStore.saveJPEG(image) {
                    photoFileNames.append(name)
                }
            }
            .ignoresSafeArea()
        }
    }

    private func mediaActionLabel(title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(AppTheme.captionFont)
            .foregroundStyle(AppTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Capsule().fill(AppTheme.mint.opacity(0.55)))
    }

    @MainActor
    private func importPickerItems(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        for item in items {
            if photoFileNames.count >= maxCount { break }
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               let name = MediaStore.saveJPEG(image) {
                photoFileNames.append(name)
            }
        }
        pickerItems = []
    }
}

// MARK: - Camera

struct CameraPicker: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(parent: CameraPicker) { self.parent = parent }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
            parent.dismiss()
        }
    }
}

// MARK: - Audio recorder UI

struct DiaryAudioRecorderSection: View {
    @Binding var audioFileName: String?
    @StateObject private var recorder = AudioRecorder()
    @StateObject private var player = AudioPlayer()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Voice Note", systemImage: "mic.fill")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.ink)

            if let audioFileName {
                AudioPlaybackBar(fileName: audioFileName, player: player)

                HStack(spacing: 10) {
                    Button {
                        player.stop()
                        recorder.requestPermissionAndRecord()
                    } label: {
                        Label(recorder.isRecording ? "Recording \(recorder.formattedElapsed)" : "Re-record", systemImage: "mic.circle.fill")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(AppTheme.butter.opacity(0.7)))
                    }
                    .buttonStyle(CartoonPressStyle())

                    if recorder.isRecording {
                        Button {
                            if let name = recorder.stop() {
                                // replace old
                                MediaStore.delete(fileName: audioFileName)
                                self.audioFileName = name
                                player.load(fileName: name)
                            }
                        } label: {
                            Label("Done", systemImage: "checkmark.circle.fill")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.ink)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(AppTheme.mint.opacity(0.7)))
                        }
                        .buttonStyle(CartoonPressStyle())
                    } else {
                        Button {
                            player.stop()
                            MediaStore.delete(fileName: audioFileName)
                            self.audioFileName = nil
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(Color(hex: 0xFF8A80))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(Color(hex: 0xFFCDD2).opacity(0.7)))
                        }
                        .buttonStyle(CartoonPressStyle())
                    }
                }
            } else {
                if recorder.isRecording {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: 0xFF8A80))
                            .frame(width: 12, height: 12)
                            .opacity(0.4 + 0.6 * abs(sin(recorder.elapsed * 4)))

                        Text("Recording \(recorder.formattedElapsed)")
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(AppTheme.ink)

                        Spacer()

                        Button {
                            recorder.cancel()
                        } label: {
                            Text("Cancel")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.inkSoft)
                        }

                        Button {
                            if let name = recorder.stop() {
                                audioFileName = name
                                player.load(fileName: name)
                            }
                        } label: {
                            Text("Done")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.ink)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(AppTheme.mint))
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(hex: 0xFFCDD2).opacity(0.35))
                    )
                } else {
                    Button {
                        recorder.requestPermissionAndRecord()
                    } label: {
                        Label("Tap to start recording", systemImage: "mic.circle.fill")
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(AppTheme.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [AppTheme.lavender.opacity(0.7), AppTheme.mint.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            )
                    }
                    .buttonStyle(CartoonPressStyle())
                }
            }

            if let message = recorder.errorMessage {
                Text(message)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(Color(hex: 0xFF8A80))
            }
            if recorder.permissionDenied {
                Text("Enable the microphone in Settings › SoftDiary")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.card)
        )
        .onAppear {
            player.load(fileName: audioFileName)
        }
        .onChange(of: audioFileName) { _, name in
            player.load(fileName: name)
        }
        .onDisappear {
            if recorder.isRecording {
                recorder.cancel()
            }
            player.stop()
        }
    }
}

struct AudioPlaybackBar: View {
    let fileName: String
    @ObservedObject var player: AudioPlayer

    var body: some View {
        HStack(spacing: 12) {
            Button {
                player.toggle()
            } label: {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color(hex: 0xC9A0FF))
            }
            .buttonStyle(CartoonPressStyle())

            VStack(alignment: .leading, spacing: 6) {
                Text("Voice Note")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSoft)
                ProgressView(value: player.duration > 0 ? player.progress / player.duration : 0)
                    .tint(Color(hex: 0xC9A0FF))
                Text("\(player.formattedProgress) / \(player.formattedDuration)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.inkSoft)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.lavender.opacity(0.28))
        )
    }
}

// MARK: - Detail / card previews

struct DiaryPhotoGallery: View {
    let fileNames: [String]

    var body: some View {
        if !fileNames.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Label("Photos", systemImage: "photo.fill")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(fileNames, id: \.self) { name in
                        if let image = MediaStore.loadImage(fileName: name) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(minHeight: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                    }
                }
            }
        }
    }
}

struct DiaryAudioDetailPlayer: View {
    let fileName: String
    @StateObject private var player = AudioPlayer()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Voice Note", systemImage: "waveform")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.ink)
            AudioPlaybackBar(fileName: fileName, player: player)
        }
        .onAppear { player.load(fileName: fileName) }
        .onDisappear { player.stop() }
    }
}
