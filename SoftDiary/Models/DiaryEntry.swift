import Foundation

struct DiaryEntry: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var date: Date
    var mood: Mood
    var title: String
    var content: String
    var createdAt: Date
    var isFavorite: Bool
    var tags: [DiaryTag]
    var pose: CharacterPose
    var prompt: String
    var sketchData: Data?
    var photoFileNames: [String]
    var audioFileName: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: Mood = .sunny,
        title: String = "",
        content: String = "",
        createdAt: Date = Date(),
        isFavorite: Bool = false,
        tags: [DiaryTag] = [],
        pose: CharacterPose = .idle,
        prompt: String = "",
        sketchData: Data? = nil,
        photoFileNames: [String] = [],
        audioFileName: String? = nil
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.tags = tags
        self.pose = pose
        self.prompt = prompt
        self.sketchData = sketchData
        self.photoFileNames = photoFileNames
        self.audioFileName = audioFileName
    }

    enum CodingKeys: String, CodingKey {
        case id, date, mood, title, content, createdAt, isFavorite, tags, pose, prompt, sketchData
        case photoFileNames, audioFileName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        mood = try container.decode(Mood.self, forKey: .mood)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        tags = try container.decodeIfPresent([DiaryTag].self, forKey: .tags) ?? []
        pose = try container.decodeIfPresent(CharacterPose.self, forKey: .pose) ?? .idle
        prompt = try container.decodeIfPresent(String.self, forKey: .prompt) ?? ""
        sketchData = try container.decodeIfPresent(Data.self, forKey: .sketchData)
        photoFileNames = try container.decodeIfPresent([String].self, forKey: .photoFileNames) ?? []
        audioFileName = try container.decodeIfPresent(String.self, forKey: .audioFileName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(mood, forKey: .mood)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(tags, forKey: .tags)
        try container.encode(pose, forKey: .pose)
        try container.encode(prompt, forKey: .prompt)
        try container.encodeIfPresent(sketchData, forKey: .sketchData)
        try container.encode(photoFileNames, forKey: .photoFileNames)
        try container.encodeIfPresent(audioFileName, forKey: .audioFileName)
    }

    var hasSketch: Bool {
        guard let sketchData, !sketchData.isEmpty else { return false }
        return true
    }

    var hasPhotos: Bool { !photoFileNames.isEmpty }
    var hasAudio: Bool { audioFileName != nil }

    var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        let preview = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if preview.isEmpty {
            if hasPhotos { return "A little photo" }
            if hasAudio { return "A voice note" }
            if hasSketch { return "A doodle" }
            return "An empty day"
        }
        return String(preview.prefix(18))
    }

    var previewText: String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if hasPhotos { return "This entry has photos." }
            if hasAudio { return "This entry has a voice note." }
            if hasSketch { return "This entry has a doodle." }
            return "Nothing written yet."
        }
        return trimmed
    }

    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
