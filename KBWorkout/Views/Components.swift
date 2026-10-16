import SwiftUI

struct ActivityRing: View {
    var progress: Double
    var color: Color
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress.clamped(to: 0...1))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding(lineWidth / 2)
    }
}

/// The coloured artwork used on workout cards and the detail header.
struct WorkoutArt: View {
    let workout: Workout
    var letterSize: CGFloat = 44
    var symbolSize: CGFloat = 56

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Theme.tile(workout.theme)
            if let badge = workout.badge {
                Text(badge)
                    .font(Theme.numerals(letterSize, .black))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.trailing, 12)
            } else {
                Image(systemName: workout.category.symbol)
                    .font(.system(size: symbolSize))
                    .foregroundStyle(.white.opacity(0.25))
                    .padding(12)
            }
        }
    }
}

struct WorkoutCard: View {
    let workout: Workout
    let minutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WorkoutArt(workout: workout)
                .overlay(alignment: .bottomLeading) {
                    Text("\(minutes) MIN")
                        .font(.system(size: 12, weight: .heavy))
                        .tracking(0.6)
                        .foregroundStyle(.white)
                        .padding(10)
                }
                .frame(width: 200, height: 116)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Text(workout.title)
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
            Text(workout.subtitle)
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondary)
                .lineLimit(1)
        }
        .frame(width: 200, alignment: .leading)
    }
}

struct Shelf: View {
    @Environment(WorkoutLibrary.self) private var library
    // Read so cards refresh when these settings change.
    @AppStorage("includeWarmup") private var includeWarmup = true
    @AppStorage("restBetweenSets") private var restBetweenSets = 60
    let title: String
    let workouts: [Workout]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 22, weight: .heavy))
                .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(workouts) { workout in
                        NavigationLink(value: workout) {
                            WorkoutCard(workout: workout, minutes: library.minutes(workout))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("workout-\(workout.id)")
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct WeekSummaryCard: View {
    let history: [CompletedWorkout]
    @AppStorage("weeklyGoalMinutes") private var goal = 90

    private var week: DateInterval? { Calendar.current.dateInterval(of: .weekOfYear, for: .now) }

    private var thisWeek: [CompletedWorkout] {
        guard let week else { return [] }
        return history.filter { week.contains($0.date) }
    }

    private var minutes: Int { Int(thisWeek.reduce(0) { $0 + $1.duration } / 60) }

    var body: some View {
        HStack(spacing: 18) {
            ActivityRing(progress: Double(minutes) / Double(max(goal, 1)), color: Theme.volt, lineWidth: 13)
                .frame(width: 84, height: 84)
            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: "This week")
                Text("\(minutes)/\(goal) MIN")
                    .font(Theme.numerals(24, .black))
                    .foregroundStyle(Theme.volt)
                Text("\(thisWeek.count) workout\(thisWeek.count == 1 ? "" : "s")")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.secondary)
                if let week {
                    WeekDots(start: week.start, dates: thisWeek.map(\.date))
                        .padding(.top, 4)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct WeekDots: View {
    let start: Date
    let dates: [Date]

    var body: some View {
        let calendar = Calendar.current
        HStack(spacing: 9) {
            ForEach(0..<7, id: \.self) { offset in
                let day = calendar.date(byAdding: .day, value: offset, to: start) ?? start
                let done = dates.contains { calendar.isDate($0, inSameDayAs: day) }
                VStack(spacing: 3) {
                    Circle()
                        .fill(done ? Theme.volt : Color.white.opacity(0.15))
                        .frame(width: 10, height: 10)
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(size: 11))
                        .foregroundStyle(calendar.isDateInToday(day) ? Color.primary : Theme.secondary)
                }
            }
        }
    }
}

/// One segment per block; the current one fills as you go.
struct SegmentBar: View {
    let count: Int
    let current: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index < current ? Theme.volt : Theme.raised)
                    .overlay(alignment: .leading) {
                        if index == current {
                            GeometryReader { geo in
                                Capsule().fill(Theme.volt)
                                    .frame(width: max(geo.size.width * progress, 5))
                            }
                        }
                    }
                    .frame(height: 5)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Part \(current + 1) of \(count)")
    }
}

struct PillButtonStyle: ButtonStyle {
    var background: Color = Theme.volt
    var foreground: Color = Theme.onVolt
    var height: CGFloat = 56

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .heavy))
            .frame(maxWidth: .infinity, minHeight: height)
            .foregroundStyle(foreground)
            .background(background, in: Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

extension View {
    /// Keeps scrolled content from showing through behind the status bar.
    func statusBarBackdrop() -> some View {
        safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 0).background(Color.black.opacity(0.92))
        }
    }
}
