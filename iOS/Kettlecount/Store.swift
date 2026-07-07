import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [SetEntry] = []
    @Published var isPro: Bool = false

    // Free-tier cap. Kept comfortably above seed-data count so a fresh
    // install never trips the paywall immediately.
    static let freeLimit = 48

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("kettlecount_entries.json")
        load()
    }

    func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([SetEntry].self, from: data) {
            entries = decoded
        } else {
            entries = [
            SetEntry(date: Date().addingTimeInterval(-0), movement: "Swing", value1: 5, value2: 3),
            SetEntry(date: Date().addingTimeInterval(-86400), movement: "Snatch", value1: 6, value2: 4),
            SetEntry(date: Date().addingTimeInterval(-172800), movement: "Get-Up", value1: 7, value2: 5)
            ]
            save()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    var totalValue1: Int { entries.reduce(0) { $0 + $1.value1 } }

    @discardableResult
    func add(movement: String, value1: Int, value2: Int, note: String = "") -> Bool {
        guard canAddMore else { return false }
        entries.insert(SetEntry(movement: movement, value1: value1, value2: value2, note: note), at: 0)
        save()
        Haptics.success()
        return true
    }

    func update(_ entry: SetEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: SetEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
}
