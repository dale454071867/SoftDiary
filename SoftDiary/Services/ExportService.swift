import SwiftUI
import UIKit

enum ExportService {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, yyyy · EEEE"
        return formatter
    }()

    static func plainText(for entry: DiaryEntry) -> String {
        var lines: [String] = []
        lines.append("[SoftDiary] \(entry.displayTitle)")
        lines.append(dateFormatter.string(from: entry.date))
        lines.append("Mood: \(entry.mood.title) · Pose: \(entry.pose.title)")
        if !entry.tags.isEmpty {
            lines.append("Tags: \(entry.tags.map(\.title).joined(separator: ", "))")
        }
        if !entry.prompt.isEmpty {
            lines.append("Prompt: \(entry.prompt)")
        }
        lines.append("")
        lines.append(entry.content.isEmpty ? entry.previewText : entry.content)
        if entry.hasPhotos { lines.append("\n(Includes \(entry.photoFileNames.count) photo(s))") }
        if entry.hasAudio { lines.append("(Includes a voice note)") }
        if entry.hasSketch { lines.append("(Includes a sketch)") }
        return lines.joined(separator: "\n")
    }

    static func plainText(for entries: [DiaryEntry]) -> String {
        let header = "SoftDiary Export\n\(entries.count) entries\n" + String(repeating: "—", count: 16) + "\n\n"
        let body = entries.map { plainText(for: $0) }.joined(separator: "\n\n" + String(repeating: "·", count: 12) + "\n\n")
        return header + body
    }

    @MainActor
    static func renderCardImage(for entry: DiaryEntry) -> UIImage? {
        let view = ExportCardView(entry: entry)
            .frame(width: 390)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    static func writeTempTextFile(_ text: String, name: String = "SoftDiary_Export.txt") -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var onComplete: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            onComplete?()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ExportCardView: View {
    let entry: DiaryEntry

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("SoftDiary")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.inkSoft)
                Spacer()
                Text(Self.dateFormatter.string(from: entry.date))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.inkSoft)
            }

            CharacterPortraitView(
                mood: entry.mood,
                pose: entry.pose,
                height: 160,
                isAnimated: false
            )

            Text(entry.displayTitle)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
                .multilineTextAlignment(.center)

            Text("\(entry.mood.title) · \(entry.pose.title)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(entry.mood.accent)

            Text(entry.previewText)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(6)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.75))
                )
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.skyTop, AppTheme.skyBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        )
    }
}
