import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Environment(WorkoutLibrary.self) private var library
    @Query(sort: \CompletedWorkout.date, order: .reverse) private var history: [CompletedWorkout]
    @AppStorage("weeklyGoalMinutes") private var goal = 90

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("History")
                        .font(.system(size: 34, weight: .heavy))
                    if history.isEmpty {
                        ContentUnavailableView("No workouts yet",
                                               systemImage: "figure.strengthtraining.functional",
                                               description: Text("Finish a workout and it will show up here."))
                            .padding(.top, 60)
                    } else {
                        WeeklyChart(weeks: lastWeeks(6), goal: goal, streak: streak)
                        ForEach(groups) { group in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(group.title).font(.system(size: 20, weight: .heavy))
                                VStack(spacing: 0) {
                                    ForEach(Array(group.entries.enumerated()), id: \.element.id) { index, entry in
                                        if index > 0 { Divider().overlay(Theme.raised).padding(.leading, 66) }
                                        HistoryRow(entry: entry, badge: library.workout(id: entry.workoutID)?.badge)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    context.delete(entry)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                                .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        Text("Touch and hold a workout to delete it.")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color.black)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func weekStart(_ date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }

    /// Minutes per week, oldest first, ending with the current week.
    private func lastWeeks(_ count: Int) -> [WeekTotal] {
        let thisWeek = weekStart(.now)
        return (0..<count).reversed().map { back in
            let start = calendar.date(byAdding: .weekOfYear, value: -back, to: thisWeek) ?? thisWeek
            let minutes = history.filter { weekStart($0.date) == start }.reduce(0) { $0 + $1.duration } / 60
            return WeekTotal(start: start, minutes: Int(minutes))
        }
    }

    /// Consecutive weeks with at least one workout, counting back from this week (or last week).
    private var streak: Int {
        let active = Set(history.map { weekStart($0.date) })
        var week = weekStart(.now)
        if !active.contains(week) { week = calendar.date(byAdding: .weekOfYear, value: -1, to: week) ?? week }
        var count = 0
        while active.contains(week) {
            count += 1
            week = calendar.date(byAdding: .weekOfYear, value: -1, to: week) ?? week
        }
        return count
    }

    private var groups: [WeekGroup] {
        let thisWeek = weekStart(.now)
        let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeek) ?? thisWeek
        var result: [WeekGroup] = []
        for entry in history {
            let start = weekStart(entry.date)
            let title = start == thisWeek ? "This Week"
                : start == lastWeek ? "Last Week"
                : "Week of \(start.formatted(.dateTime.day().month()))"
            if result.last?.title == title {
                result[result.count - 1].entries.append(entry)
            } else {
                result.append(WeekGroup(title: title, entries: [entry]))
            }
        }
        return result
    }
}

private struct WeekTotal {
    let start: Date
    let minutes: Int
}

private struct WeekGroup: Identifiable {
    let title: String
    var entries: [CompletedWorkout]
    var id: String { title }
}

private struct WeeklyChart: View {
    let weeks: [WeekTotal]
    let goal: Int
    let streak: Int

    private var average: Int {
        weeks.isEmpty ? 0 : weeks.reduce(0) { $0 + $1.minutes } / weeks.count
    }

    var body: some View {
        let top = Double(max(goal, weeks.map(\.minutes).max() ?? 0)) * 1.15
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Eyebrow(text: "Minutes per week")
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(average)").font(Theme.numerals(26, .black)).foregroundStyle(Theme.volt)
                        Text("avg, last \(weeks.count) weeks")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.secondary)
                    }
                }
                Spacer()
                if streak > 1 {
                    Text("\(streak)-week streak")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.elapsed)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.elapsed.opacity(0.15), in: Capsule())
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    let goalY = geo.size.height * (1 - Double(goal) / top)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: goalY))
                        path.addLine(to: CGPoint(x: geo.size.width, y: goalY))
                    }
                    .stroke(Color(hex: 0x48484A), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    Text("goal \(goal)")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondary)
                        .position(x: geo.size.width - 24, y: max(goalY - 9, 6))
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(Array(weeks.enumerated()), id: \.offset) { index, week in
                            UnevenRoundedRectangle(topLeadingRadius: 6, topTrailingRadius: 6)
                                .fill(index == weeks.count - 1 ? Theme.volt : Theme.volt.opacity(0.45))
                                .frame(height: max(geo.size.height * Double(week.minutes) / top, 2))
                        }
                    }
                }
            }
            .frame(height: 110)
            HStack(spacing: 10) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { index, week in
                    Text(index == weeks.count - 1 ? "Now" : week.start.formatted(.dateTime.day().month(.abbreviated)))
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct HistoryRow: View {
    let entry: CompletedWorkout
    let badge: String?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(Theme.tile(entry.theme))
                if let badge {
                    Text(badge).font(Theme.numerals(18, .black))
                } else {
                    Image(systemName: "figure.strengthtraining.functional").font(.system(size: 18))
                }
            }
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title).font(.system(size: 16, weight: .bold))
                Text(meta).font(.system(size: 13)).foregroundStyle(Theme.secondary)
                if !entry.notes.isEmpty {
                    Text(entry.notes).font(.system(size: 13)).foregroundStyle(Theme.secondary).lineLimit(2)
                }
            }
            Spacer(minLength: 0)
            Text(Effort.label(entry.effort))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.effortColor(entry.effort))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.effortColor(entry.effort).opacity(0.15), in: Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var meta: String {
        var parts = [entry.date.formatted(.dateTime.weekday(.abbreviated).day().month()),
                     "\(Int((entry.duration / 60).rounded())) min",
                     "\(Int(entry.bellWeightKg)) kg"]
        if !entry.completed { parts.append("ended early") }
        return parts.joined(separator: " · ")
    }
}
