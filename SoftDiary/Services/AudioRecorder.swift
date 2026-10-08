import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var elapsed: TimeInterval = 0
    @Published var permissionDenied = false
    @Published var errorMessage: String?

    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private(set) var currentFileName: String?
    private var currentURL: URL?

    var formattedElapsed: String {
        let total = Int(elapsed)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    func requestPermissionAndRecord() {
        Task {
            let granted: Bool
            if #available(iOS 17.0, *) {
                granted = await AVAudioApplication.requestRecordPermission()
            } else {
                granted = await withCheckedContinuation { cont in
                    AVAudioSession.sharedInstance().requestRecordPermission { cont.resume(returning: $0) }
                }
            }
            if granted {
                permissionDenied = false
                start()
            } else {
                permissionDenied = true
                errorMessage = "Please allow microphone access in Settings"
            }
        }
    }

    func start() {
        stopTimer()
        errorMessage = nil

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            errorMessage = "Could not start recording"
            return
        }

        let fileName = MediaStore.makeAudioFileName()
        let url = MediaStore.url(for: fileName)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.delegate = self
            recorder.record()
            self.recorder = recorder
            currentFileName = fileName
            currentURL = url
            isRecording = true
            elapsed = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.elapsed = self?.recorder?.currentTime ?? 0
                }
            }
        } catch {
            errorMessage = "Recording failed"
            currentFileName = nil
            currentURL = nil
        }
    }

    @discardableResult
    func stop() -> String? {
        guard isRecording else { return currentFileName }
        recorder?.stop()
        recorder = nil
        isRecording = false
        stopTimer()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        return currentFileName
    }

    func cancel() {
        let name = currentFileName
        stop()
        MediaStore.delete(fileName: name)
        currentFileName = nil
        currentURL = nil
        elapsed = 0
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if !flag {
                errorMessage = "Recording did not finish"
            }
        }
    }
}

@MainActor
final class AudioPlayer: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var duration: TimeInterval = 0

    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var fileName: String?

    var formattedProgress: String {
        let total = Int(progress)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    var formattedDuration: String {
        let total = Int(duration)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    func load(fileName: String?) {
        stop()
        self.fileName = fileName
        guard let fileName else {
            duration = 0
            return
        }
        let url = MediaStore.url(for: fileName)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            self.player = player
            duration = player.duration
            progress = 0
        } catch {
            self.player = nil
            duration = 0
        }
    }

    func toggle() {
        guard let player else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
            stopTimer()
        } else {
            player.play()
            isPlaying = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    guard let self, let player = self.player else { return }
                    self.progress = player.currentTime
                }
            }
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        progress = 0
        stopTimer()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            progress = duration
            stopTimer()
        }
    }
}
