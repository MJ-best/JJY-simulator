import Foundation

/// A single 1-second JJY time-code pulse symbol.
enum JJYSymbol: UInt8, Equatable, Hashable, Sendable {
    /// Binary 0: carrier stays high for 0.8 s.
    case zero = 0
    /// Binary 1: carrier stays high for 0.5 s.
    case one = 1
    /// Position / frame marker (M or P1–P5): carrier stays high for 0.2 s.
    case marker = 2

    /// Duration in seconds that the carrier stays high from the start of the second.
    var highDuration: Double {
        switch self {
        case .zero: return 0.8
        case .one: return 0.5
        case .marker: return 0.2
        }
    }

    var character: Character {
        switch self {
        case .zero: return "0"
        case .one: return "1"
        case .marker: return "M"
        }
    }
}

/// Target JJY station frequency and its 1/3 audio fundamental carrier frequency.
enum JJYFrequency: Int, CaseIterable, Identifiable, Sendable {
    /// Fukushima (40 kHz) via 13.333 kHz 3rd harmonic.
    case khz40 = 40
    /// Kyushu (60 kHz) via 20 kHz 3rd harmonic.
    case khz60 = 60

    var id: Int { rawValue }

    /// Audio fundamental sine frequency in Hz whose 3rd harmonic matches the JJY carrier.
    var carrierHz: Double {
        switch self {
        case .khz40: return 40_000.0 / 3.0
        case .khz60: return 20_000.0
        }
    }

    var label: String {
        "\(rawValue)kHz"
    }
}

/// Wall-clock calendar fields encoded into a 1-minute JJY time-code frame.
struct JJYFields: Equatable, Hashable, Sendable {
    /// Full Gregorian year (e.g. 2026).
    let year: Int
    /// 1-based day of year (1...366).
    let dayOfYear: Int
    /// Hour in 24-hour format (0...23; midnight is 0, never 24).
    let hour: Int
    /// Minute (0...59).
    let minute: Int
    /// Day of week where 0 = Sunday ... 6 = Saturday.
    let weekday: Int
}

/// Lock-free, allocation-free bit-packed representation of a 60-second JJY frame
/// suitable for direct reading inside a real-time CoreAudio render callback.
struct PackedJJYMinute: Equatable, Sendable {
    let unixMinute: Int64
    let lo: UInt64
    let hi: UInt64

    static let empty = PackedJJYMinute(unixMinute: Int64.min, lo: 0, hi: 0)

    init(unixMinute: Int64, lo: UInt64, hi: UInt64) {
        self.unixMinute = unixMinute
        self.lo = lo
        self.hi = hi
    }

    init(unixMinute: Int64, symbols: [JJYSymbol]) {
        var loBits: UInt64 = 0
        var hiBits: UInt64 = 0
        let count = min(60, symbols.count)
        for i in 0..<count {
            let code = UInt64(symbols[i].rawValue)
            let mask: UInt64 = 1 << UInt64(i)
            if (code & 1) != 0 { loBits |= mask }
            if (code & 2) != 0 { hiBits |= mask }
        }
        self.unixMinute = unixMinute
        self.lo = loBits
        self.hi = hiBits
    }

    @inline(__always)
    func symbol(atSecond second: Int) -> JJYSymbol? {
        guard second >= 0 && second < 60 else { return nil }
        let shift = UInt64(second)
        let code = UInt8(((lo >> shift) & 1) | (((hi >> shift) & 1) << 1))
        return JJYSymbol(rawValue: code)
    }

    @inline(__always)
    func highDuration(atSecond second: Int) -> Double {
        guard second >= 0 && second < 60 else { return 0.0 }
        let shift = UInt64(second)
        let code = ((lo >> shift) & 1) | (((hi >> shift) & 1) << 1)
        switch code {
        case 0: return 0.8
        case 1: return 0.5
        default: return 0.2
        }
    }
}

/// JJY time code encoder (NICT spec).
/// The watch assumes the received frame is JST, so encoding another time zone's
/// wall-clock time causes the watch to display that zone's local time.
enum JJYCode {
    static func isLeapYear(_ year: Int) -> Bool {
        (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }

    static func dayOfYear(year: Int, month: Int, day: Int) -> Int {
        let cumulative = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
        let m = max(1, min(12, month))
        let leap = (m > 2 && isLeapYear(year)) ? 1 : 0
        return cumulative[m - 1] + leap + day
    }

    /// Wall-clock fields of `date` in `timeZone` (DST handled automatically by Foundation).
    static func fields(for date: Date, in timeZone: TimeZone) -> JJYFields {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: date)
        let year = comps.year ?? 1970
        let month = comps.month ?? 1
        let day = comps.day ?? 1
        let hour = (comps.hour ?? 0) % 24
        let minute = comps.minute ?? 0
        let weekday = ((comps.weekday ?? 1) - 1 + 7) % 7
        return JJYFields(
            year: year,
            dayOfYear: dayOfYear(year: year, month: month, day: day),
            hour: hour,
            minute: minute,
            weekday: weekday
        )
    }

    /// Generates the 60 symbols for one JJY minute frame.
    static func frame(for fields: JJYFields) -> [JJYSymbol] {
        let mi = bcd(fields.minute, weights: [40, 20, 10, 8, 4, 2, 1])
        let hr = bcd(fields.hour, weights: [20, 10, 8, 4, 2, 1])
        let doy = bcd(fields.dayOfYear, weights: [200, 100, 80, 40, 20, 10, 8, 4, 2, 1])
        let yr = bcd(fields.year % 100, weights: [80, 40, 20, 10, 8, 4, 2, 1])
        let wd = bcd(fields.weekday, weights: [4, 2, 1])

        let m: JJYSymbol = .marker
        let z: JJYSymbol = .zero
        let sym: (Int) -> JJYSymbol = { $0 == 0 ? .zero : .one }

        var out: [JJYSymbol] = []
        out.reserveCapacity(60)

        // 0-9: minute
        out.append(m)
        out.append(contentsOf: mi[0..<3].map(sym))
        out.append(z)
        out.append(contentsOf: mi[3..<7].map(sym))
        out.append(m)

        // 10-19: hour
        out.append(contentsOf: [z, z])
        out.append(contentsOf: hr[0..<2].map(sym))
        out.append(z)
        out.append(contentsOf: hr[2..<6].map(sym))
        out.append(m)

        // 20-29: day of year (high digits)
        out.append(contentsOf: [z, z])
        out.append(contentsOf: doy[0..<2].map(sym))
        out.append(z)
        out.append(contentsOf: doy[2..<6].map(sym))
        out.append(m)

        // 30-39: day of year (low digits), PA1 (hour parity), PA2 (minute parity), SU1
        out.append(contentsOf: doy[6..<10].map(sym))
        out.append(contentsOf: [z, z, sym(parity(hr)), sym(parity(mi)), z, m])

        // 40-49: SU2, year
        out.append(z)
        out.append(contentsOf: yr.map(sym))
        out.append(m)

        // 50-59: weekday, LS1/LS2
        out.append(contentsOf: wd.map(sym))
        out.append(contentsOf: [z, z, z, z, z, z, m])

        return out
    }

    static func frameString(for fields: JJYFields) -> String {
        String(frame(for: fields).map(\.character))
    }

    static func packedMinute(unixMinute: Int64, in timeZone: TimeZone) -> PackedJJYMinute {
        let date = Date(timeIntervalSince1970: TimeInterval(unixMinute * 60))
        let symbols = frame(for: fields(for: date, in: timeZone))
        return PackedJJYMinute(unixMinute: unixMinute, symbols: symbols)
    }

    private static func bcd(_ value: Int, weights: [Int]) -> [Int] {
        var v = value
        return weights.map { w in
            if v >= w {
                v -= w
                return 1
            } else {
                return 0
            }
        }
    }

    private static func parity(_ bits: [Int]) -> Int {
        bits.reduce(0, ^)
    }
}
