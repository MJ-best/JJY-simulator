import SwiftUI
import UIKit

/// Controls JJY carrier frequency (40kHz / 60kHz), Start/Stop transmission,
/// live blinking carrier lamp, and 60-second JJY time-code pulse visualizer.
struct TransmitterCard: View {
    let frequency: JJYFrequency
    let isTransmitting: Bool
    let timeZone: TimeZone
    let errorMessage: String?
    let onSelectFrequency: (JJYFrequency) -> Void
    let onToggleTransmission: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Frequency selector (40kHz / 60kHz)
            HStack(spacing: 8) {
                ForEach(JJYFrequency.allCases) { freq in
                    let selected = freq == frequency
                    Button {
                        onSelectFrequency(freq)
                    } label: {
                        Text(freq.label)
                            .font(.body.weight(selected ? .bold : .regular))
                            .foregroundStyle(Theme.fg(for: colorScheme))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selected ? Theme.band(for: colorScheme) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(
                                        selected ? Theme.accent(for: colorScheme) : Theme.line(for: colorScheme),
                                        lineWidth: selected ? 1.5 : 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text("freq.accessibility"))

            // Start / Stop button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onToggleTransmission()
            } label: {
                Text(LocalizedStringKey(isTransmitting ? "tx.stop" : "tx.start"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isTransmitting ? Color.white : Theme.accentFg(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isTransmitting ? Theme.stopRed : Theme.accent(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Theme.stopRed)
            }

            // Live carrier lamp + status + 60-second JJY time-code bars
            TimelineView(.periodic(from: .now, by: isTransmitting ? 0.05 : 0.25)) { context in
                let now = context.date
                let unix = now.timeIntervalSince1970
                let secFloor = floor(unix)
                let frac = unix - secFloor
                let second = (Int(Int64(secFloor) % 60) + 60) % 60
                let bits = JJYCode.frame(for: JJYCode.fields(for: now, in: timeZone))
                let lampLit = isTransmitting && frac < bits[second].highDuration

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(lampLit ? Theme.lampOn : Theme.line(for: colorScheme))
                            .frame(width: 14, height: 14)
                            .shadow(color: lampLit ? Theme.lampOn.opacity(0.85) : .clear, radius: 6)

                        Text(statusText)
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted(for: colorScheme))
                    }

                    // 60-second pulse-width visualizer
                    Canvas { canvasCtx, size in
                        let barCount = 60
                        let gap: CGFloat = 1.0
                        let barWidth = max(1.0, (size.width - gap * CGFloat(barCount - 1)) / CGFloat(barCount))
                        let normalColor = Theme.muted(for: colorScheme).opacity(0.45)
                        let markerColor = Theme.fg(for: colorScheme).opacity(0.80)

                        for i in 0..<min(barCount, bits.count) {
                            let symbol = bits[i]
                            let barHeight = size.height * CGFloat(symbol.highDuration)
                            let x = CGFloat(i) * (barWidth + gap)
                            let y = size.height - barHeight
                            let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)

                            let color: Color
                            if i == second && isTransmitting {
                                color = Theme.lampOn
                            } else if symbol == .marker {
                                color = markerColor
                            } else {
                                color = normalColor
                            }

                            canvasCtx.fill(
                                Path(roundedRect: rect, cornerRadius: 1),
                                with: .color(color)
                            )
                        }
                    }
                    .frame(height: 40)
                    .accessibilityHidden(true)
                }
            }
        }
        .simulatorCard()
    }

    private var statusText: String {
        if isTransmitting {
            let tx = NSLocalizedString("tx.transmitting", comment: "")
            return "\(tx) · \(frequency.label)"
        }
        return NSLocalizedString("tx.idle", comment: "")
    }
}
