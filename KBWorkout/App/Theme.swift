import SwiftUI

enum Theme {
    static let volt = Color(hex: 0xC4F23A)
    static let onVolt = Color(hex: 0x0B0F00)
    static let rest = Color(hex: 0x5AC8FA)
    static let onRest = Color(hex: 0x001018)
    static let elapsed = Color(hex: 0xFFD60A)
    static let danger = Color(hex: 0xFF453A)
    static let hard = Color(hex: 0xFF9F0A)
    static let card = Color(hex: 0x1C1C1E)
    static let raised = Color(hex: 0x2C2C2E)
    static let secondary = Color(hex: 0xA1A1A6)

    static func tile(_ theme: String) -> Color {
        switch theme {
        case "ember": Color(hex: 0xD9480F)
        case "ocean": Color(hex: 0x1D5FD6)
        case "violet": Color(hex: 0x7A3FD1)
        case "teal": Color(hex: 0x0E7C66)
        case "rose": Color(hex: 0xB0247A)
        case "volt": Color(hex: 0x3F7D16)
        default: Color(hex: 0x3A4250)
        }
    }

    static func effortColor(_ effort: Int) -> Color {
        switch effort {
        case ...2: rest
        case 3: volt
        default: hard
        }
    }

    /// Rounded numerals, like the Fitness app.
    static func numerals(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

extension TimeInterval {
    /// 1:05 or 1:02:03. Countdowns round up; elapsed time should round down.
    func clock(_ rule: FloatingPointRoundingRule = .up) -> String {
        let total = Int(rounded(rule).clamped(to: 0...359_999))
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self { min(max(self, range.lowerBound), range.upperBound) }
}

/// Small grey uppercase label used throughout.
struct Eyebrow: View {
    let text: String
    var color: Color = Theme.secondary

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(color)
    }
}
