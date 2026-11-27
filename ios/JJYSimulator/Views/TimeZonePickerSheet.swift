import SwiftUI

/// Searchable modal sheet listing Major Cities (with the device's zone first) and All IANA Time Zones.
struct TimeZonePickerSheet: View {
    let selectedZoneID: String
    let deviceZoneID: String
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @State private var searchText = ""

    private var majorZones: [String] {
        filter(CityCatalog.majorZoneIDs(deviceZoneID: deviceZoneID))
    }

    private var allZones: [String] {
        filter(CityCatalog.allKnownZoneIDs)
    }

    var body: some View {
        NavigationStack {
            List {
                if !majorZones.isEmpty {
                    Section(header: Text("tz.major")) {
                        ForEach(majorZones, id: \.self) { zoneID in
                            zoneRow(zoneID)
                        }
                    }
                }

                if !allZones.isEmpty {
                    Section(header: Text("tz.all")) {
                        ForEach(allZones, id: \.self) { zoneID in
                            zoneRow(zoneID)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("tz.search.placeholder")
            )
            .navigationTitle(Text("tz.picker.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func zoneRow(_ zoneID: String) -> some View {
        let name = CityCatalog.displayName(for: zoneID, locale: locale)
        let isDevice = zoneID == deviceZoneID
        let isSelected = zoneID == selectedZoneID
        let offset = CityCatalog.formatUTCOffset(minutes: CityCatalog.utcOffsetMinutes(for: zoneID))

        Button {
            onSelect(zoneID)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(name)
                            .font(.body.weight(isSelected ? .semibold : .regular))
                            .foregroundStyle(.primary)

                        if isDevice {
                            Text("tz.device")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                        }
                    }

                    Text(zoneID)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(offset)
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func filter(_ zones: [String]) -> [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return zones }
        return zones.filter { zoneID in
            if zoneID.localizedCaseInsensitiveContains(query) { return true }
            if let city = CityCatalog.city(for: zoneID) {
                return city.ko.localizedCaseInsensitiveContains(query)
                    || city.en.localizedCaseInsensitiveContains(query)
                    || city.ja.localizedCaseInsensitiveContains(query)
            }
            return CityCatalog.displayName(for: zoneID, locale: locale)
                .localizedCaseInsensitiveContains(query)
        }
    }
}
