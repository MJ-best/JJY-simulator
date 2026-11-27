import SwiftUI

/// Light & Dark color palette matching style.css in the web version.
enum Theme {
    static func bg(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x0F1115) : Color(hex: 0xF4F5F7)
    }

    static func card(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x1A1D23) : Color(hex: 0xFFFFFF)
    }

    static func fg(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0xE8EAED) : Color(hex: 0x1B1D21)
    }

    static func muted(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x9AA0A6) : Color(hex: 0x6B7280)
    }

    static func line(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x2A2E35) : Color(hex: 0xE3E5E8)
    }

    static func accent(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x60A5FA) : Color(hex: 0x2563EB)
    }

    static func accentFg(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x0B1220) : Color(hex: 0xFFFFFF)
    }

    static func sea(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x13233A) : Color(hex: 0xDBE7F3)
    }

    static func land(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x3B4A3A) : Color(hex: 0xB9C7B0)
    }

    static func band(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(hex: 0x60A5FA).opacity(0.25)
            : Color(hex: 0x2563EB).opacity(0.20)
    }

    static func grid(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.13)
            : Color.white.opacity(0.67)
    }

    static let lampOn = Color(hex: 0xF59E0B)
    static let stopRed = Color(hex: 0xDC2626)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

struct SimulatorCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card(for: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Theme.line(for: colorScheme), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func simulatorCard() -> some View {
        modifier(SimulatorCardModifier())
    }
}
