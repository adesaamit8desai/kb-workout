import Foundation
import SwiftData

@Model
final class CompletedWorkout {
    var workoutID: String
    var title: String
    var theme: String
    var date: Date
    var duration: TimeInterval
    var completed: Bool
    var bellWeightKg: Double
    /// 1 (easy) to 5 (max).
    var effort: Int
    var notes: String
    var setsDone: Int
    var setsTotal: Int

    init(workoutID: String, title: String, theme: String, date: Date, duration: TimeInterval, completed: Bool,
         bellWeightKg: Double, effort: Int, notes: String, setsDone: Int, setsTotal: Int) {
        self.workoutID = workoutID
        self.title = title
        self.theme = theme
        self.date = date
        self.duration = duration
        self.completed = completed
        self.bellWeightKg = bellWeightKg
        self.effort = effort
        self.notes = notes
        self.setsDone = setsDone
        self.setsTotal = setsTotal
    }
}

enum Effort {
    static let labels = ["Easy", "Light", "Good", "Hard", "Max"]

    static func label(_ value: Int) -> String {
        labels[(value - 1).clamped(to: 0...4)]
    }
}
