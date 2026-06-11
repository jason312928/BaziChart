import Foundation

struct AdministrativeArea: Identifiable, Codable, Hashable, Sendable {
    let code: String
    let province: String
    let city: String
    let district: String

    var id: String { code }
    var displayName: String { "\(province) \(city) \(district)" }
    var shortName: String { "\(city) \(district)" }
    var searchableName: String { "\(province)\(city)\(district)\(code)" }
    var normalizedName: String {
        LocationIndex.normalize("\(province)\(city)\(district)")
    }
}

enum LocationService {
    static let shared = LocationIndex()
}

struct LocationIndex: Sendable {
    let areas: [AdministrativeArea]

    private let longitudeOverrides: [String: Double] = [
        "310112": 121.38, "310101": 121.49, "310104": 121.44, "310105": 121.42,
        "310106": 121.45, "310107": 121.40, "310109": 121.51, "310110": 121.52,
        "310113": 121.49, "310114": 121.27, "310115": 121.54, "310116": 121.34,
        "310117": 121.23, "310118": 121.12, "310120": 121.47, "310151": 121.40,
        "440103": 113.24, "440104": 113.27, "440105": 113.32, "440106": 113.36,
        "440111": 113.27, "440112": 113.48, "440113": 113.38, "440114": 113.22,
        "440115": 113.54, "440117": 113.59, "440118": 113.81,
        "440303": 114.13, "440304": 114.05, "440305": 113.93, "440306": 113.90,
        "440307": 114.25, "440308": 114.24, "440309": 114.04, "440310": 114.35,
        "440311": 113.94
    ]

    private let cityLongitude: [String: Double] = [
        "北京市": 116.40, "上海市": 121.47, "天津市": 117.20, "重庆市": 106.55,
        "广州市": 113.26, "深圳市": 114.06, "珠海市": 113.57, "汕头市": 116.68,
        "佛山市": 113.12, "韶关市": 113.60, "湛江市": 110.36, "肇庆市": 112.47,
        "江门市": 113.08, "茂名市": 110.92, "惠州市": 114.42, "梅州市": 116.12,
        "汕尾市": 115.38, "河源市": 114.70, "阳江市": 111.98, "清远市": 113.03,
        "东莞市": 113.75, "中山市": 113.39, "潮州市": 116.63, "揭阳市": 116.36,
        "云浮市": 112.04, "杭州市": 120.16, "南京市": 118.80, "成都市": 104.07,
        "武汉市": 114.31, "西安市": 108.94, "郑州市": 113.62
    ]

    init() {
        if let url = Bundle.module.url(forResource: "AreaIndex", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([AdministrativeArea].self, from: data) {
            areas = decoded
        } else {
            areas = []
        }
    }

    func search(_ query: String, limit: Int = 200) -> [AdministrativeArea] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return Array(areas.prefix(limit))
        }
        let tokens = trimmed
            .split { $0.isWhitespace || $0 == "/" || $0 == "," || $0 == "，" }
            .map(String.init)
        let normalizedTokens = tokens.map(Self.normalize)

        return areas
            .lazy
            .compactMap { area -> (AdministrativeArea, Int)? in
                let scores = zip(tokens, normalizedTokens).compactMap { token, normalizedToken in
                    matchScore(area: area, token: token, normalizedToken: normalizedToken)
                }
                guard scores.count == tokens.count else { return nil }
                return (area, scores.reduce(0, +))
            }
            .sorted {
                if $0.1 != $1.1 { return $0.1 > $1.1 }
                if $0.0.city != $1.0.city { return $0.0.city < $1.0.city }
                return $0.0.district < $1.0.district
            }
            .prefix(limit)
            .map(\.0)
    }

    static func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "特别行政区", with: "")
            .replacingOccurrences(of: "自治区", with: "")
            .replacingOccurrences(of: "自治州", with: "")
            .replacingOccurrences(of: "自治县", with: "")
            .replacingOccurrences(of: "省", with: "")
            .replacingOccurrences(of: "市", with: "")
            .replacingOccurrences(of: "区", with: "")
            .replacingOccurrences(of: "县", with: "")
    }

    private func matchScore(area: AdministrativeArea, token: String, normalizedToken: String) -> Int? {
        let searchable = area.searchableName.lowercased()
        let normalized = area.normalizedName

        if area.code == token { return 1_000 }
        if area.district == token { return 900 }
        if area.city == token { return 840 }
        if area.province == token { return 800 }
        if area.district.localizedCaseInsensitiveContains(token) { return 720 }
        if area.city.localizedCaseInsensitiveContains(token) { return 680 }
        if searchable.contains(token.lowercased()) { return 620 }
        if !normalizedToken.isEmpty, normalized.contains(normalizedToken) { return 560 }
        if !normalizedToken.isEmpty, isSubsequence(normalizedToken, of: normalized) { return 360 }
        return nil
    }

    private func isSubsequence(_ needle: String, of haystack: String) -> Bool {
        var iterator = haystack.makeIterator()
        for character in needle {
            var matched = false
            while let candidate = iterator.next() {
                if candidate == character {
                    matched = true
                    break
                }
            }
            if !matched { return false }
        }
        return true
    }

    func longitude(for area: AdministrativeArea) -> Double {
        longitudeOverrides[area.code] ?? cityLongitude[area.city] ?? cityLongitude[area.province] ?? 120.0
    }
}
