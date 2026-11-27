import SwiftUI

/// Offline Natural Earth 110m equirectangular land geometry bundled in WorldLand.json.
/// Coordinates live in the 1000×500 equirectangular projection cropped to y ∈ [20, 410] (height 390),
/// matching the SVG viewBox="0 20 1000 390" in the web version.
final class WorldMapData: @unchecked Sendable {
    static let mapWidth: CGFloat = 1000
    static let mapHeight: CGFloat = 500
    static let viewMinY: CGFloat = 20
    static let viewHeight: CGFloat = 390

    static let shared = WorldMapData.load(from: .main)

    /// Prebuilt path translated into the cropped 1000×390 viewBox coordinate space.
    let landPath: Path
    let ringCount: Int

    private init(rings: [[Double]]) {
        var path = Path()
        for ring in rings where ring.count >= 6 {
            let start = CGPoint(x: ring[0], y: ring[1] - Double(Self.viewMinY))
            path.move(to: start)
            var i = 2
            while i + 1 < ring.count {
                path.addLine(to: CGPoint(x: ring[i], y: ring[i + 1] - Double(Self.viewMinY)))
                i += 2
            }
            path.closeSubpath()
        }
        self.landPath = path
        self.ringCount = rings.count
    }

    static func load(from bundle: Bundle) -> WorldMapData {
        guard let url = bundle.url(forResource: "WorldLand", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rings = try? JSONDecoder().decode([[Double]].self, from: data) else {
            return WorldMapData(rings: [])
        }
        return WorldMapData(rings: rings)
    }

    static func mapX(longitude: Double) -> CGFloat {
        CGFloat((longitude + 180.0) / 360.0) * mapWidth
    }

    static func mapY(latitude: Double) -> CGFloat {
        CGFloat((90.0 - latitude) / 180.0) * mapHeight
    }

    static func coordinates(fromMapPoint point: CGPoint) -> (latitude: Double, longitude: Double) {
        let lon = Double(point.x / mapWidth) * 360.0 - 180.0
        let lat = 90.0 - Double(point.y / mapHeight) * 180.0
        return (lat, lon)
    }
}
