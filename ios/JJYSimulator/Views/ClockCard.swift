import SwiftUI

/// Displays the selected city's live local time, date, UTC offset, and time zone selector.
struct ClockCard: View {
    let selectedZoneID: String
    let deviceZoneID: String
    let onSelectZone: (String) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.locale) private var locale
    @State private var showingPicker = false

    private var selectedTimeZone: TimeZone {
        TimeZone(identifier: selectedZoneID) ?? .current
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TimelineView(.periodic(from: .now, by: 0.25)) { context in
                let now = context.date
                let fields = JJYCode.fields(for: now, in: selectedTimeZone)
                let sec = Int(floor(now.timeIntervalSince1970)) % 60
                let normalizedSec = (sec + 60) % 60
                let offsetMin = CityCatalog.utcOffsetMinutes(for: selectedZoneID, at: now)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(CityCatalog.displayName(for: selectedZoneID, locale: locale))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.fg(for: colorScheme))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Spacer(minLength: 12)

                        Text(CityCatalog.formatUTCOffset(minutes: offsetMin))
                            .font(.body)
                            .foregroundStyle(Theme.muted(for: colorScheme))
                    }

                    Text(String(format: "%02d:%02d:%02d", fields.hour, fields.minute, normalizedSec))
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .monospacedDigit()
                        .foregroundStyle(Theme.fg(for: colorScheme))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.top, 2)

                    Text(formattedDate(now))
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted(for: colorScheme))
                }
            }

            Button {
                showingPicker = true
            } label: {
                HStack(spacing: 8) {
                    Text(selectorLabel)
                        .font(.body)
                        .foregroundStyle(Theme.fg(for: colorScheme))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.muted(for: colorScheme))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Theme.bg(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Theme.line(for: colorScheme), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
            .accessibilityLabel(Text("tz.picker.accessibility"))
            .sheet(isPresented: $showingPicker) {
                TimeZonePickerSheet(
                    selectedZoneID: selectedZoneID,
                    deviceZoneID: deviceZoneID
                ) { picked in
                    onSelectZone(picked)
                }
            }
        }
        .simulatorCard()
    }

    private var selectorLabel: String {
        let name = CityCatalog.displayName(for: selectedZoneID, locale: locale)
        if selectedZoneID == deviceZoneID {
            let deviceTag = NSLocalizedString("tz.device", comment: "")
            return "\(name) · \(deviceTag) (\(selectedZoneID))"
        }
        return "\(name) (\(selectedZoneID))"
    }

    private func formattedDate(_ date: Date) -> String {
        let style = Date.FormatStyle(
            date: .complete,
            time: .omitted,
            locale: locale,
            calendar: Calendar(identifier: .gregorian),
            timeZone: selectedTimeZone
        )
        return date.formatted(style)
    }
}
