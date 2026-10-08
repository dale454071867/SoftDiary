import Foundation
import UIKit

enum MediaStore {
    private static var root: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("SoftDiaryMedia", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func url(for fileName: String) -> URL {
        root.appendingPathComponent(fileName)
    }

    static func saveJPEG(_ image: UIImage, quality: CGFloat = 0.72) -> String? {
        let resized = image.softDiaryResized(maxSide: 1600)
        guard let data = resized.jpegData(compressionQuality: quality) else { return nil }
        let name = "img_\(UUID().uuidString).jpg"
        let url = url(for: name)
        do {
            try data.write(to: url, options: .atomic)
            return name
        } catch {
            return nil
        }
    }

    static func loadImage(fileName: String) -> UIImage? {
        let url = url(for: fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func makeAudioFileName() -> String {
        "aud_\(UUID().uuidString).m4a"
    }

    static func delete(fileName: String?) {
        guard let fileName else { return }
        let url = url(for: fileName)
        try? FileManager.default.removeItem(at: url)
    }

    static func delete(fileNames: [String]) {
        fileNames.forEach { delete(fileName: $0) }
    }
}

extension UIImage {
    func softDiaryResized(maxSide: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxSide else { return self }
        let scale = maxSide / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
