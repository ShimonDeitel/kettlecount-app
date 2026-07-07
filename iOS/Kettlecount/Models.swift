import Foundation

struct SetEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var movement: String   // Movement
    var value1: Int   // Weight (kg)
    var value2: Int   // Reps
    var note: String = ""
}

enum KettlecountOptions {
    static let all: [String] = ["Swing", "Snatch", "Get-Up", "Clean", "Press", "Windmill"]
}
