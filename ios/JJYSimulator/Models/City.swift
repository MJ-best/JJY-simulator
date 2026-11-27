import Foundation

/// Curated world city shown on the map and in the major-cities time zone list.
struct City: Identifiable, Hashable, Sendable {
    let zoneID: String
    let lat: Double
    let lon: Double
    let ko: String
    let en: String
    let ja: String

    var id: String { zoneID }

    func localizedName(for locale: Locale = .current) -> String {
        switch locale.language.languageCode?.identifier {
        case "ko": return ko
        case "ja": return ja
        default: return en
        }
    }
}

/// Curated 62 cities (ordered west to east, matching app.js) plus time zone helpers.
enum CityCatalog {
    static let all: [City] = [
        City(zoneID: "Pacific/Pago_Pago", lat: -14.28, lon: -170.7, ko: "아메리칸사모아", en: "Pago Pago", ja: "パゴパゴ"),
        City(zoneID: "Pacific/Honolulu", lat: 21.31, lon: -157.86, ko: "호놀룰루", en: "Honolulu", ja: "ホノルル"),
        City(zoneID: "America/Anchorage", lat: 61.22, lon: -149.9, ko: "앵커리지", en: "Anchorage", ja: "アンカレッジ"),
        City(zoneID: "America/Vancouver", lat: 49.28, lon: -123.12, ko: "밴쿠버", en: "Vancouver", ja: "バンクーバー"),
        City(zoneID: "America/Los_Angeles", lat: 34.05, lon: -118.24, ko: "로스앤젤레스", en: "Los Angeles", ja: "ロサンゼルス"),
        City(zoneID: "America/Phoenix", lat: 33.45, lon: -112.07, ko: "피닉스", en: "Phoenix", ja: "フェニックス"),
        City(zoneID: "America/Denver", lat: 39.74, lon: -104.99, ko: "덴버", en: "Denver", ja: "デンバー"),
        City(zoneID: "America/Mexico_City", lat: 19.43, lon: -99.13, ko: "멕시코시티", en: "Mexico City", ja: "メキシコシティ"),
        City(zoneID: "America/Chicago", lat: 41.88, lon: -87.63, ko: "시카고", en: "Chicago", ja: "シカゴ"),
        City(zoneID: "America/Cancun", lat: 21.16, lon: -86.85, ko: "칸쿤", en: "Cancún", ja: "カンクン"),
        City(zoneID: "America/Toronto", lat: 43.65, lon: -79.38, ko: "토론토", en: "Toronto", ja: "トロント"),
        City(zoneID: "America/Lima", lat: -12.05, lon: -77.04, ko: "리마", en: "Lima", ja: "リマ"),
        City(zoneID: "America/New_York", lat: 40.71, lon: -74.01, ko: "뉴욕", en: "New York", ja: "ニューヨーク"),
        City(zoneID: "America/Bogota", lat: 4.71, lon: -74.07, ko: "보고타", en: "Bogotá", ja: "ボゴタ"),
        City(zoneID: "America/Santiago", lat: -33.45, lon: -70.67, ko: "산티아고", en: "Santiago", ja: "サンティアゴ"),
        City(zoneID: "America/Halifax", lat: 44.65, lon: -63.57, ko: "핼리팩스", en: "Halifax", ja: "ハリファックス"),
        City(zoneID: "America/Argentina/Buenos_Aires", lat: -34.6, lon: -58.38, ko: "부에노스아이레스", en: "Buenos Aires", ja: "ブエノスアイレス"),
        City(zoneID: "America/Sao_Paulo", lat: -23.55, lon: -46.63, ko: "상파울루", en: "São Paulo", ja: "サンパウロ"),
        City(zoneID: "Atlantic/Reykjavik", lat: 64.15, lon: -21.94, ko: "레이캬비크", en: "Reykjavík", ja: "レイキャビク"),
        City(zoneID: "Europe/Lisbon", lat: 38.72, lon: -9.14, ko: "리스본", en: "Lisbon", ja: "リスボン"),
        City(zoneID: "Europe/London", lat: 51.51, lon: -0.13, ko: "런던", en: "London", ja: "ロンドン"),
        City(zoneID: "Europe/Madrid", lat: 40.42, lon: -3.7, ko: "마드리드", en: "Madrid", ja: "マドリード"),
        City(zoneID: "Europe/Paris", lat: 48.86, lon: 2.35, ko: "파리", en: "Paris", ja: "パリ"),
        City(zoneID: "Africa/Lagos", lat: 6.52, lon: 3.38, ko: "라고스", en: "Lagos", ja: "ラゴス"),
        City(zoneID: "Europe/Rome", lat: 41.9, lon: 12.5, ko: "로마", en: "Rome", ja: "ローマ"),
        City(zoneID: "Europe/Berlin", lat: 52.52, lon: 13.4, ko: "베를린", en: "Berlin", ja: "ベルリン"),
        City(zoneID: "Europe/Athens", lat: 37.98, lon: 23.73, ko: "아테네", en: "Athens", ja: "アテネ"),
        City(zoneID: "Europe/Helsinki", lat: 60.17, lon: 24.94, ko: "헬싱키", en: "Helsinki", ja: "ヘルシンキ"),
        City(zoneID: "Africa/Johannesburg", lat: -26.2, lon: 28.05, ko: "요하네스버그", en: "Johannesburg", ja: "ヨハネスブルグ"),
        City(zoneID: "Europe/Istanbul", lat: 41.01, lon: 28.98, ko: "이스탄불", en: "Istanbul", ja: "イスタンブール"),
        City(zoneID: "Africa/Cairo", lat: 30.04, lon: 31.24, ko: "카이로", en: "Cairo", ja: "カイロ"),
        City(zoneID: "Africa/Nairobi", lat: -1.29, lon: 36.82, ko: "나이로비", en: "Nairobi", ja: "ナイロビ"),
        City(zoneID: "Europe/Moscow", lat: 55.76, lon: 37.62, ko: "모스크바", en: "Moscow", ja: "モスクワ"),
        City(zoneID: "Asia/Tehran", lat: 35.69, lon: 51.39, ko: "테헤란", en: "Tehran", ja: "テヘラン"),
        City(zoneID: "Asia/Dubai", lat: 25.2, lon: 55.27, ko: "두바이", en: "Dubai", ja: "ドバイ"),
        City(zoneID: "Asia/Karachi", lat: 24.86, lon: 67.01, ko: "카라치", en: "Karachi", ja: "カラチ"),
        City(zoneID: "Asia/Almaty", lat: 43.24, lon: 76.89, ko: "알마티", en: "Almaty", ja: "アルマトイ"),
        City(zoneID: "Asia/Kolkata", lat: 28.61, lon: 77.21, ko: "델리", en: "Delhi", ja: "デリー"),
        City(zoneID: "Asia/Kathmandu", lat: 27.72, lon: 85.32, ko: "카트만두", en: "Kathmandu", ja: "カトマンズ"),
        City(zoneID: "Asia/Dhaka", lat: 23.81, lon: 90.41, ko: "다카", en: "Dhaka", ja: "ダッカ"),
        City(zoneID: "Asia/Bangkok", lat: 13.76, lon: 100.5, ko: "방콕", en: "Bangkok", ja: "バンコク"),
        City(zoneID: "Asia/Singapore", lat: 1.35, lon: 103.82, ko: "싱가포르", en: "Singapore", ja: "シンガポール"),
        City(zoneID: "Asia/Ho_Chi_Minh", lat: 10.82, lon: 106.63, ko: "호찌민", en: "Ho Chi Minh City", ja: "ホーチミン"),
        City(zoneID: "Asia/Jakarta", lat: -6.21, lon: 106.85, ko: "자카르타", en: "Jakarta", ja: "ジャカルタ"),
        City(zoneID: "Asia/Ulaanbaatar", lat: 47.89, lon: 106.91, ko: "울란바토르", en: "Ulaanbaatar", ja: "ウランバートル"),
        City(zoneID: "Asia/Hong_Kong", lat: 22.32, lon: 114.17, ko: "홍콩", en: "Hong Kong", ja: "香港"),
        City(zoneID: "Asia/Makassar", lat: -8.65, lon: 115.22, ko: "발리", en: "Bali", ja: "バリ"),
        City(zoneID: "Australia/Perth", lat: -31.95, lon: 115.86, ko: "퍼스", en: "Perth", ja: "パース"),
        City(zoneID: "Asia/Shanghai", lat: 39.9, lon: 116.4, ko: "베이징", en: "Beijing", ja: "北京"),
        City(zoneID: "Asia/Manila", lat: 14.6, lon: 120.98, ko: "마닐라", en: "Manila", ja: "マニラ"),
        City(zoneID: "Asia/Taipei", lat: 25.03, lon: 121.57, ko: "타이베이", en: "Taipei", ja: "台北"),
        City(zoneID: "Asia/Seoul", lat: 37.57, lon: 126.98, ko: "서울", en: "Seoul", ja: "ソウル"),
        City(zoneID: "Australia/Darwin", lat: -12.46, lon: 130.84, ko: "다윈", en: "Darwin", ja: "ダーウィン"),
        City(zoneID: "Asia/Vladivostok", lat: 43.12, lon: 131.89, ko: "블라디보스토크", en: "Vladivostok", ja: "ウラジオストク"),
        City(zoneID: "Australia/Adelaide", lat: -34.93, lon: 138.6, ko: "애들레이드", en: "Adelaide", ja: "アデレード"),
        City(zoneID: "Asia/Tokyo", lat: 35.68, lon: 139.69, ko: "도쿄", en: "Tokyo", ja: "東京"),
        City(zoneID: "Pacific/Guam", lat: 13.44, lon: 144.79, ko: "괌", en: "Guam", ja: "グアム"),
        City(zoneID: "Pacific/Saipan", lat: 15.18, lon: 145.75, ko: "사이판", en: "Saipan", ja: "サイパン"),
        City(zoneID: "Australia/Sydney", lat: -33.87, lon: 151.21, ko: "시드니", en: "Sydney", ja: "シドニー"),
        City(zoneID: "Australia/Brisbane", lat: -27.47, lon: 153.03, ko: "브리즈번", en: "Brisbane", ja: "ブリスベン"),
        City(zoneID: "Pacific/Auckland", lat: -36.85, lon: 174.76, ko: "오클랜드", en: "Auckland", ja: "オークランド"),
        City(zoneID: "Pacific/Fiji", lat: -18.14, lon: 178.44, ko: "피지", en: "Fiji", ja: "フィジー"),
    ]

    static let byZoneID: [String: City] = Dictionary(uniqueKeysWithValues: all.map { ($0.zoneID, $0) })

    static func city(for zoneID: String) -> City? {
        byZoneID[zoneID]
    }

    static func displayName(for zoneID: String, locale: Locale = .current) -> String {
        if let city = byZoneID[zoneID] {
            return city.localizedName(for: locale)
        }
        return zoneID.split(separator: "/").last
            .map { $0.replacingOccurrences(of: "_", with: " ") } ?? zoneID
    }

    /// Major city zone IDs with the device's current time zone placed first (deduplicated).
    static func majorZoneIDs(deviceZoneID: String = TimeZone.current.identifier) -> [String] {
        var result: [String] = []
        var seen = Set<String>()
        for z in [deviceZoneID] + all.map(\.zoneID) where seen.insert(z).inserted {
            result.append(z)
        }
        return result
    }

    /// All IANA time zone identifiers supported by iOS.
    static let allKnownZoneIDs: [String] = TimeZone.knownTimeZoneIdentifiers.sorted()

    /// Finds the nearest curated city to the tapped geographic coordinates,
    /// matching app.js's cosine-weighted wrap-around distance metric.
    static func nearestCity(latitude lat: Double, longitude lon: Double) -> City {
        let k = cos(lat * .pi / 180.0)
        func distSq(_ c: City) -> Double {
            let rawDiff = (c.lon - lon).truncatingRemainder(dividingBy: 360.0)
            let wrapped = (rawDiff + 540.0).truncatingRemainder(dividingBy: 360.0) - 180.0
            let dx = wrapped * k
            let dy = c.lat - lat
            return dy * dy + dx * dx
        }
        return all.min { distSq($0) < distSq($1) } ?? all[0]
    }

    /// Current UTC offset in minutes for `zoneID` at `date` (including DST).
    static func utcOffsetMinutes(for zoneID: String, at date: Date = Date()) -> Int {
        let tz = TimeZone(identifier: zoneID) ?? .current
        return tz.secondsFromGMT(for: date) / 60
    }

    /// Formats a UTC offset in minutes (e.g. `UTC+9`, `UTC−4`, `UTC+5:30`).
    static func formatUTCOffset(minutes: Int) -> String {
        let sign = minutes < 0 ? "\u{2212}" : "+"
        let absMin = abs(minutes)
        let hours = absMin / 60
        let rem = absMin % 60
        if rem == 0 {
            return "UTC\(sign)\(hours)"
        } else {
            return String(format: "UTC%@%d:%02d", sign, hours, rem)
        }
    }
}
