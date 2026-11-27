import XCTest
@testable import JJYSimulator

final class JJYCodeTests: XCTestCase {
    private func isoDate(_ string: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        return try XCTUnwrap(formatter.date(from: string))
    }

    func testTokyoFrameMatchesWebSpec() throws {
        // 2026-10-18T04:07:00Z -> 2026-10-18 13:07 JST, Sunday, day 291.
        // Hour 13 and minute 7 both have odd parity.
        let date = try isoDate("2026-10-18T04:07:00Z")
        let tokyoTZ = try XCTUnwrap(TimeZone(identifier: "Asia/Tokyo"))
        let fields = JJYCode.fields(for: date, in: tokyoTZ)

        XCTAssertEqual(fields, JJYFields(year: 2026, dayOfYear: 291, hour: 13, minute: 7, weekday: 0))
        XCTAssertEqual(
            JJYCode.frameString(for: fields),
            "M00000111M" + "000100011M" + "001001001M" + "000100110M" + "000100110M" + "000000000M"
        )
    }

    func testNewYorkMidnightIsZeroNotTwentyFour() throws {
        // New York (EDT, UTC-4) -> 00:07 same day; midnight must be 0, not 24.
        let date = try isoDate("2026-10-18T04:07:00Z")
        let nyTZ = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        let fields = JJYCode.fields(for: date, in: nyTZ)

        XCTAssertEqual(fields, JJYFields(year: 2026, dayOfYear: 291, hour: 0, minute: 7, weekday: 0))
    }

    func testLeapYearDayOfYear366() throws {
        let date = try isoDate("2028-12-31T12:00:00Z")
        let utc = try XCTUnwrap(TimeZone(identifier: "UTC"))
        XCTAssertEqual(JJYCode.fields(for: date, in: utc).dayOfYear, 366)
    }

    func testPackedJJYMinuteRoundTrip() throws {
        let date = try isoDate("2026-10-18T04:07:00Z")
        let tokyoTZ = try XCTUnwrap(TimeZone(identifier: "Asia/Tokyo"))
        let unixMinute = Int64(date.timeIntervalSince1970) / 60
        let expected = JJYCode.frame(for: JJYCode.fields(for: date, in: tokyoTZ))
        let packed = JJYCode.packedMinute(unixMinute: unixMinute, in: tokyoTZ)

        XCTAssertEqual(packed.unixMinute, unixMinute)
        for sec in 0..<60 {
            XCTAssertEqual(packed.symbol(atSecond: sec), expected[sec], "Mismatch at second \(sec)")
            XCTAssertEqual(packed.highDuration(atSecond: sec), expected[sec].highDuration, accuracy: 1e-9)
        }
    }

    func testCityCatalogAndNearestCity() {
        XCTAssertEqual(CityCatalog.all.count, 62)

        // Tap near Seoul
        XCTAssertEqual(CityCatalog.nearestCity(latitude: 37.5, longitude: 127.0).zoneID, "Asia/Seoul")
        // Tap near Tokyo
        XCTAssertEqual(CityCatalog.nearestCity(latitude: 35.7, longitude: 139.7).zoneID, "Asia/Tokyo")
        // Antimeridian wrap-around: -179° is very close to Fiji (+178.44°), not London
        XCTAssertEqual(CityCatalog.nearestCity(latitude: -18.0, longitude: -179.0).zoneID, "Pacific/Fiji")
    }

    func testUTCOffsetFormatting() {
        XCTAssertEqual(CityCatalog.formatUTCOffset(minutes: 540), "UTC+9")
        XCTAssertEqual(CityCatalog.formatUTCOffset(minutes: 0), "UTC+0")
        XCTAssertEqual(CityCatalog.formatUTCOffset(minutes: -240), "UTC\u{2212}4")
        XCTAssertEqual(CityCatalog.formatUTCOffset(minutes: 330), "UTC+5:30")
        XCTAssertEqual(CityCatalog.formatUTCOffset(minutes: 345), "UTC+5:45")
    }

    func testOfflineWorldMapDecodes() {
        let mapData = WorldMapData.load(from: Bundle(for: WorldMapData.self))
        XCTAssertEqual(mapData.ringCount, 129)
        XCTAssertFalse(mapData.landPath.isEmpty)
    }
}
