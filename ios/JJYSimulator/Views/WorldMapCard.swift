import SwiftUI
import UIKit

private struct MapContainerWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        if next > 0 { value = next }
    }
}

/// Interactive offline world map showing UTC longitude bands and the 62 curated cities.
/// Tapping anywhere selects the nearest city's time zone.
struct WorldMapCard: View {
    let selectedZoneID: String
    let onSelectZone: (String) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.locale) private var locale

    @State private var containerWidth: CGFloat = 0
    @State private var hasCenteredInitially: Bool = false

    private let anchorSlotCount = 72
    private let mapData = WorldMapData.shared

    private var selectedCity: City? {
        CityCatalog.city(for: selectedZoneID)
    }

    private var utcOffsetMinutes: Int {
        CityCatalog.utcOffsetMinutes(for: selectedZoneID)
    }

    private var targetLongitude: Double {
        if let city = selectedCity {
            return city.lon
        }
        return Double(utcOffsetMinutes) / 4.0
    }

    private var targetAnchorSlot: Int {
        let normalized = ((targetLongitude + 180.0).truncatingRemainder(dividingBy: 360.0) + 360.0)
            .truncatingRemainder(dividingBy: 360.0) / 360.0
        let raw = Int((normalized * Double(anchorSlotCount)).rounded())
        return max(0, min(anchorSlotCount - 1, raw))
    }

    var body: some View {
        let mapWidth = max(containerWidth, 720)
        let mapHeight = mapWidth * (WorldMapData.viewHeight / WorldMapData.mapWidth)

        VStack(alignment: .leading, spacing: 8) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        // Lightweight horizontal anchor grid enabling smooth centering on iOS 16+.
                        HStack(spacing: 0) {
                            ForEach(0..<anchorSlotCount, id: \.self) { slot in
                                Color.clear
                                    .frame(width: mapWidth / CGFloat(anchorSlotCount), height: 1)
                                    .id(slot)
                            }
                        }

                        mapCanvas(mapWidth: mapWidth, mapHeight: mapHeight)
                            .frame(width: mapWidth, height: mapHeight)
                            .contentShape(Rectangle())
                            .onTapGesture(coordinateSpace: .local) { location in
                                handleTap(at: location, mapWidth: mapWidth)
                            }
                    }
                    .frame(width: mapWidth, height: mapHeight)
                }
                .frame(height: mapHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: MapContainerWidthKey.self, value: geo.size.width)
                    }
                )
                .onPreferenceChange(MapContainerWidthKey.self) { width in
                    guard width > 0, abs(width - containerWidth) > 0.5 else { return }
                    containerWidth = width
                    if !hasCenteredInitially {
                        hasCenteredInitially = true
                        proxy.scrollTo(targetAnchorSlot, anchor: .center)
                    }
                }
                .onAppear {
                    if containerWidth > 0 && !hasCenteredInitially {
                        hasCenteredInitially = true
                        proxy.scrollTo(targetAnchorSlot, anchor: .center)
                    }
                }
                .onChange(of: selectedZoneID) { _ in
                    withAnimation(.easeInOut(duration: 0.35)) {
                        proxy.scrollTo(targetAnchorSlot, anchor: .center)
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("map.accessibility"))

            Text("map.hint")
                .font(.footnote)
                .foregroundStyle(Theme.muted(for: colorScheme))
        }
        .simulatorCard()
    }

    @ViewBuilder
    private func mapCanvas(mapWidth: CGFloat, mapHeight: CGFloat) -> some View {
        let offsetMinutes = utcOffsetMinutes
        let activeZone = selectedZoneID
        let activeCity = selectedCity
        let currentScheme = colorScheme
        let currentLocale = locale

        Canvas { context, size in
            let scale = size.width / WorldMapData.mapWidth

            // 1. Sea background
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Theme.sea(for: currentScheme))
            )

            // 2. Blue UTC time-zone band (15° wide)
            let bandLonLeft = Double(offsetMinutes) / 4.0 - 7.5
            let bandX = WorldMapData.mapX(longitude: bandLonLeft) * scale
            let bandWidth = (15.0 / 360.0) * size.width
            let bandColor = Theme.band(for: currentScheme)

            context.fill(
                Path(CGRect(x: bandX, y: 0, width: bandWidth, height: size.height)),
                with: .color(bandColor)
            )
            // Wrap band across the ±180° edge for UTC+12 / UTC-12 zones.
            if bandX < 0 {
                context.fill(
                    Path(CGRect(x: bandX + size.width, y: 0, width: bandWidth, height: size.height)),
                    with: .color(bandColor)
                )
            } else if bandX + bandWidth > size.width {
                context.fill(
                    Path(CGRect(x: bandX - size.width, y: 0, width: bandWidth, height: size.height)),
                    with: .color(bandColor)
                )
            }

            // 3. Offline Natural Earth land polygons (even-odd fill preserves inland sea holes)
            let scaledLand = mapData.landPath.applying(CGAffineTransform(scaleX: scale, y: scale))
            context.fill(
                scaledLand,
                with: .color(Theme.land(for: currentScheme)),
                style: FillStyle(eoFill: true)
            )

            // 4. Longitude grid lines & UTC offset labels (-12 ... +12)
            var gridPath = Path()
            for k in -12..<12 {
                let x = WorldMapData.mapX(longitude: Double(k) * 15.0 + 7.5) * scale
                gridPath.move(to: CGPoint(x: x, y: 0))
                gridPath.addLine(to: CGPoint(x: x, y: size.height))
            }
            context.stroke(gridPath, with: .color(Theme.grid(for: currentScheme)), lineWidth: 1)

            let labelFontSize = max(9.5, 13.0 * scale)
            let labelY = (36.0 - WorldMapData.viewMinY) * scale
            let mutedColor = Theme.muted(for: currentScheme)
            for k in -12...12 {
                let x = WorldMapData.mapX(longitude: Double(k) * 15.0) * scale
                let label = (k > 0 ? "+" : "") + "\(k)"
                let resolved = context.resolve(
                    Text(label)
                        .font(.system(size: labelFontSize))
                        .foregroundColor(mutedColor)
                )
                context.draw(resolved, at: CGPoint(x: x, y: labelY), anchor: .center)
            }

            // 5. City dots
            let dotColor = Theme.fg(for: currentScheme).opacity(0.55)
            let activeDotColor = Theme.accent(for: currentScheme)
            let normalR = 4.0 * scale
            let activeR = 7.0 * scale

            for city in CityCatalog.all {
                let cx = WorldMapData.mapX(longitude: city.lon) * scale
                let cy = (WorldMapData.mapY(latitude: city.lat) - WorldMapData.viewMinY) * scale
                let isSelected = city.zoneID == activeZone
                let r = isSelected ? activeR : normalR
                let rect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
                context.fill(Path(ellipseIn: rect), with: .color(isSelected ? activeDotColor : dotColor))
            }

            // 6. Selected city pin label with halo outline
            if let city = activeCity {
                let east = city.lon > 140.0
                let pinX = (WorldMapData.mapX(longitude: city.lon) + (east ? -12.0 : 12.0)) * scale
                let pinY = (WorldMapData.mapY(latitude: city.lat) - WorldMapData.viewMinY) * scale
                let anchor: UnitPoint = east ? .trailing : .leading

                let name = city.localizedName(for: currentLocale)
                let font = Font.system(size: max(12.0, 18.0 * scale), weight: .bold)
                let haloText = context.resolve(Text(name).font(font).foregroundColor(Theme.card(for: currentScheme)))
                let fgText = context.resolve(Text(name).font(font).foregroundColor(Theme.fg(for: currentScheme)))

                let stroke = max(1.2, 2.0 * scale)
                for dx in [-stroke, 0, stroke] {
                    for dy in [-stroke, 0, stroke] where !(dx == 0 && dy == 0) {
                        context.draw(haloText, at: CGPoint(x: pinX + dx, y: pinY + dy), anchor: anchor)
                    }
                }
                context.draw(fgText, at: CGPoint(x: pinX, y: pinY), anchor: anchor)
            }
        }
    }

    private func handleTap(at location: CGPoint, mapWidth: CGFloat) {
        let scale = mapWidth / WorldMapData.mapWidth
        guard scale > 0 else { return }
        let mapPoint = CGPoint(
            x: location.x / scale,
            y: location.y / scale + WorldMapData.viewMinY
        )
        let (lat, lon) = WorldMapData.coordinates(fromMapPoint: mapPoint)
        let nearest = CityCatalog.nearestCity(latitude: lat, longitude: lon)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onSelectZone(nearest.zoneID)
    }
}
