import Foundation
import Combine

@MainActor
final class DiaryStore: ObservableObject {
    @Published private(set) var entries: [DiaryEntry] = []

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documents.appendingPathComponent("soft_diary_entries.json")
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        load()
        if entries.isEmpty {
            seedDemoIfNeeded()
        }
    }

    var sortedEntries: [DiaryEntry] {
        entries.sorted {
            if $0.date != $1.date { return $0.date > $1.date }
            return $0.createdAt > $1.createdAt
        }
    }

    var favoriteEntries: [DiaryEntry] {
        sortedEntries.filter(\.isFavorite)
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let days = Set(entries.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        var cursor = calendar.startOfDay(for: Date())
        while days.contains(cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    func entries(on day: Date) -> [DiaryEntry] {
        let calendar = Calendar.current
        return sortedEntries.filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    func moodCounts() -> [(Mood, Int)] {
        let grouped = Dictionary(grouping: entries, by: \.mood)
        return Mood.allCases.map { mood in
            (mood, grouped[mood]?.count ?? 0)
        }
    }

    func filtered(
        query: String,
        mood: Mood?,
        tag: DiaryTag?,
        favoritesOnly: Bool
    ) -> [DiaryEntry] {
        sortedEntries.filter { entry in
            if favoritesOnly && !entry.isFavorite { return false }
            if let mood, entry.mood != mood { return false }
            if let tag, !entry.tags.contains(tag) { return false }
            let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if q.isEmpty { return true }
            return entry.title.localizedCaseInsensitiveContains(q)
                || entry.content.localizedCaseInsensitiveContains(q)
                || entry.prompt.localizedCaseInsensitiveContains(q)
        }
    }

    func add(_ entry: DiaryEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: DiaryEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index] = entry
        save()
    }

    func toggleFavorite(_ entry: DiaryEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index].isFavorite.toggle()
        save()
    }

    func delete(_ entry: DiaryEntry) {
        MediaStore.delete(fileNames: entry.photoFileNames)
        MediaStore.delete(fileName: entry.audioFileName)
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            entries = try decoder.decode([DiaryEntry].self, from: data)
        } catch {
            entries = []
        }
    }

    private func save() {
        do {
            let data = try encoder.encode(entries)
            try data.write(to: fileURL, options: [.atomic])
        } catch {}
    }

    private func seedDemoIfNeeded() {
        let calendar = Calendar.current
        let today = Date()
        entries = [
            DiaryEntry(
                date: today,
                mood: .sunny,
                title: "Such a sunny day",
                content: "On my walk I saw an orange kitten blink at me. The whole world felt softer for a second.",
                tags: [.life, .random],
                pose: .cheer,
                prompt: "What moment do you want to keep today?"
            ),
            DiaryEntry(
                date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                mood: .curious,
                title: "Want to build a little app",
                content: "The UI should feel cute, the motion should bounce, and journaling itself should feel joyful.",
                isFavorite: true,
                tags: [.dream, .work],
                pose: .wave,
                prompt: "A note for tomorrow’s you: remember…"
            ),
            DiaryEntry(
                date: calendar.date(byAdding: .day, value: -2, to: today) ?? today,
                mood: .sleepy,
                title: "Nap plan: success",
                content: "The pillow was too perfect. Even my portrait looked ready for a snooze.",
                tags: [.life],
                pose: .sleep
            ),
            DiaryEntry(
                date: calendar.date(byAdding: .day, value: -3, to: today) ?? today,
                mood: .calm,
                title: "Quiet evening",
                content: "Made hot cocoa and tucked today’s feelings gently into a little box.",
                tags: [.life, .food],
                pose: .sit,
                prompt: "Say something kind to yourself."
            ),
            DiaryEntry(
                date: calendar.date(byAdding: .day, value: -5, to: today) ?? today,
                mood: .rainy,
                title: "Rain is okay too",
                content: "Walking under an umbrella, the puddles held a wobbly whole sky.",
                tags: [.travel],
                pose: .sit
            )
        ]
        save()
    }
}
