import Foundation
import LunarSwift

enum Gender: String, CaseIterable, Identifiable, Codable, Sendable {
    case male = "男"
    case female = "女"

    var id: String { rawValue }
}

enum HeavenlyStem: String, CaseIterable, Identifiable, Sendable {
    case jia = "甲", yi = "乙", bing = "丙", ding = "丁", wu = "戊"
    case ji = "己", geng = "庚", xin = "辛", ren = "壬", gui = "癸"

    var id: String { rawValue }
    var index: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    var element: FiveElement {
        switch self {
        case .jia, .yi: .wood
        case .bing, .ding: .fire
        case .wu, .ji: .earth
        case .geng, .xin: .metal
        case .ren, .gui: .water
        }
    }

    var polarity: Polarity {
        index.isMultiple(of: 2) ? .yang : .yin
    }
}

enum EarthlyBranch: String, CaseIterable, Identifiable, Sendable {
    case zi = "子", chou = "丑", yin = "寅", mao = "卯", chen = "辰", si = "巳"
    case wu = "午", wei = "未", shen = "申", you = "酉", xu = "戌", hai = "亥"

    var id: String { rawValue }
    var index: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    var element: FiveElement {
        switch self {
        case .yin, .mao: .wood
        case .si, .wu: .fire
        case .chen, .xu, .chou, .wei: .earth
        case .shen, .you: .metal
        case .zi, .hai: .water
        }
    }

    var hiddenStems: [HeavenlyStem] {
        switch self {
        case .zi: [.gui]
        case .chou: [.ji, .gui, .xin]
        case .yin: [.jia, .bing, .wu]
        case .mao: [.yi]
        case .chen: [.wu, .yi, .gui]
        case .si: [.bing, .wu, .geng]
        case .wu: [.ding, .ji]
        case .wei: [.ji, .ding, .yi]
        case .shen: [.geng, .ren, .wu]
        case .you: [.xin]
        case .xu: [.wu, .xin, .ding]
        case .hai: [.ren, .jia]
        }
    }
}

enum FiveElement: String, CaseIterable, Sendable {
    case wood = "木"
    case fire = "火"
    case earth = "土"
    case metal = "金"
    case water = "水"

    var tintName: String {
        switch self {
        case .wood: "green"
        case .fire: "red"
        case .earth: "gold"
        case .metal: "gray"
        case .water: "blue"
        }
    }
}

enum Polarity: Sendable {
    case yang
    case yin
}

enum PillarKind: String, CaseIterable, Sendable {
    case year = "年柱"
    case month = "月柱"
    case day = "日柱"
    case hour = "时柱"
}

struct Ganzhi: Identifiable, Equatable, Sendable {
    let stem: HeavenlyStem
    let branch: EarthlyBranch

    var id: String { text }
    var text: String { stem.rawValue + branch.rawValue }

    static func at(_ index: Int) -> Ganzhi {
        let normalized = ((index % 60) + 60) % 60
        return Ganzhi(
            stem: HeavenlyStem.allCases[normalized % 10],
            branch: EarthlyBranch.allCases[normalized % 12]
        )
    }

    var cycleIndex: Int {
        (0..<60).first { Ganzhi.at($0) == self } ?? 0
    }
}

struct Pillar: Identifiable, Equatable, Sendable {
    let kind: PillarKind
    let ganzhi: Ganzhi
    let tenGod: String
    let hidden: [HiddenStem]
    let star: String
    let voidBranch: String
    let nayin: String

    var id: String { kind.rawValue }
}

struct HiddenStem: Identifiable, Equatable, Sendable {
    let stem: HeavenlyStem
    let tenGod: String

    var id: String { stem.rawValue + tenGod }
    var text: String { stem.rawValue + tenGod }
}

struct LuckColumn: Identifiable, Equatable, Sendable {
    let id = UUID()
    let startYear: Int
    let ageRange: String
    let ganzhi: Ganzhi
    let topTenGod: String
    let bottomTenGod: String
    let isCurrent: Bool
}

struct FlowColumn: Identifiable, Equatable, Sendable {
    let id = UUID()
    let title: String
    let subtitle: String
    let date: Date
    let ganzhi: Ganzhi
    let topTenGod: String
    let bottomTenGod: String
}

struct FlowDay: Identifiable, Equatable, Sendable {
    let id = UUID()
    let date: Date
    let ganzhi: Ganzhi
    let topTenGod: String
    let bottomTenGod: String
    let lunarHint: String
}

struct BaziChart: Equatable, Sendable {
    let name: String
    let gender: Gender
    let birthDate: Date
    let adjustedBirthDate: Date
    let targetDate: Date
    let locationName: String
    let longitude: Double
    let useTrueSolarTime: Bool
    let calibrationText: String
    let sourceText: String
    let solarDescription: String
    let lunarDescription: String
    let dayMaster: HeavenlyStem
    let pillars: [Pillar]
    let luckStartText: String
    let luckColumns: [LuckColumn]
    let annualFlows: [FlowColumn]
    let monthlyFlows: [FlowColumn]
    let dailyFlows: [FlowDay]
    let annualFlowsByLuckStartYear: [Int: [FlowColumn]]
    let elementSummary: String

    var copyText: String {
        let pillarText = pillars.map { pillar in
            let hidden = pillar.hidden.map(\.text).joined(separator: " ")
            return "\(pillar.kind.rawValue)：\(pillar.ganzhi.text) \(pillar.tenGod)，藏干：\(hidden)，星运：\(pillar.star)，空亡：\(pillar.voidBranch)，纳音：\(pillar.nayin)"
        }.joined(separator: "\n")

        let luckText = luckColumns.map {
            "\($0.startYear) \($0.ageRange)：\($0.ganzhi.text) 天干\($0.topTenGod) 地支\($0.bottomTenGod)"
        }.joined(separator: "\n")

        let annualText = annualFlows.map {
            "\($0.title)：\($0.ganzhi.text) 天干\($0.topTenGod) 地支\($0.bottomTenGod)"
        }.joined(separator: "\n")

        let monthlyText = monthlyFlows.map {
            "\($0.title) \($0.subtitle)：\($0.ganzhi.text) 天干\($0.topTenGod) 地支\($0.bottomTenGod)"
        }.joined(separator: "\n")

        let dailyText = dailyFlows.map {
            "\($0.date.compactChineseDate)：\($0.ganzhi.text) 天干\($0.topTenGod) 地支\($0.bottomTenGod) \($0.lunarHint)"
        }.joined(separator: "\n")

        return """
        八字排盘
        姓名：\(name)
        性别：\(gender.rawValue)
        地区：\(locationName) 经度\(String(format: "%.2f", longitude))°
        校准：\(calibrationText)
        出生：\(solarDescription)
        排盘时间：\(adjustedBirthDate.fullChineseDateTime)
        算法：\(sourceText)
        查询：\(targetDate.compactChineseDate)
        日主：\(dayMaster.rawValue)
        五行：\(elementSummary)

        四柱：
        \(pillarText)

        起运：
        \(luckStartText)

        大运：
        \(luckText)

        流年：
        \(annualText)

        流月：
        \(monthlyText)

        流日：
        \(dailyText)
        """
    }
}

struct SavedProfile: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var gender: Gender
    var birthDate: Date
    var targetDate: Date
    var locationName: String
    var longitude: Double
    var useTrueSolarTime: Bool
    var savedAt: Date

    var title: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "未命名档案" : name
    }
}

struct LocationPreset: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let longitude: Double

    static let presets: [LocationPreset] = [
        .init(id: "beijing", name: "北京", longitude: 116.40),
        .init(id: "shanghai", name: "上海", longitude: 121.47),
        .init(id: "guangzhou", name: "广州", longitude: 113.26),
        .init(id: "shenzhen", name: "深圳", longitude: 114.06),
        .init(id: "chengdu", name: "成都", longitude: 104.07),
        .init(id: "xian", name: "西安", longitude: 108.94),
        .init(id: "wuhan", name: "武汉", longitude: 114.31),
        .init(id: "hangzhou", name: "杭州", longitude: 120.16),
        .init(id: "chongqing", name: "重庆", longitude: 106.55),
        .init(id: "custom", name: "自定义", longitude: 120.00)
    ]
}

struct SolarTerm {
    let month: Int
    let day: Int
    let name: String
}

struct CalculationTimingStep: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let milliseconds: Double
}

struct BaziCalculationTiming: Sendable {
    var steps: [CalculationTimingStep] = []

    var totalMilliseconds: Double {
        steps.reduce(0) { $0 + $1.milliseconds }
    }

    mutating func record(_ name: String, since start: TimeInterval) {
        steps.append(
            CalculationTimingStep(
                name: name,
                milliseconds: (ProcessInfo.processInfo.systemUptime - start) * 1_000
            )
        )
    }
}

enum BaziCalculator {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        return calendar
    }()

    static func chart(name: String, gender: Gender, birthDate: Date, targetDate: Date, locationName: String, longitude: Double, useTrueSolarTime: Bool) -> BaziChart {
        chartWithTiming(
            name: name,
            gender: gender,
            birthDate: birthDate,
            targetDate: targetDate,
            locationName: locationName,
            longitude: longitude,
            useTrueSolarTime: useTrueSolarTime
        ).chart
    }

    static func chartWithTiming(
        name: String,
        gender: Gender,
        birthDate: Date,
        targetDate: Date,
        locationName: String,
        longitude: Double,
        useTrueSolarTime: Bool
    ) -> (chart: BaziChart, timing: BaziCalculationTiming) {
        var timing = BaziCalculationTiming()

        var stepStart = ProcessInfo.processInfo.systemUptime
        let adjustedBirthDate = useTrueSolarTime ? trueSolarDate(from: birthDate, longitude: longitude) : birthDate
        timing.record("真太阳时校正", since: stepStart)

        stepStart = ProcessInfo.processInfo.systemUptime
        let birthSolar = solar(from: adjustedBirthDate)
        let lunar = birthSolar.lunar
        let eightChar = lunar.eightChar
        let dayMaster = stem(from: eightChar.dayGan)
        let ganzhis = [
            ganzhi(from: eightChar.year),
            ganzhi(from: eightChar.month),
            ganzhi(from: eightChar.day),
            ganzhi(from: eightChar.time)
        ]
        let ganGods = [eightChar.yearShiShenGan, eightChar.monthShiShenGan, "元男", eightChar.timeShiShenGan]
        let hideGans = [eightChar.yearHideGan, eightChar.monthHideGan, eightChar.dayHideGan, eightChar.timeHideGan]
        let diShi = [eightChar.yearDiShi, eightChar.monthDiShi, eightChar.dayDiShi, eightChar.timeDiShi]
        let xunKong = [eightChar.yearXunKong, eightChar.monthXunKong, eightChar.dayXunKong, eightChar.timeXunKong]
        let naYin = [eightChar.yearNaYin, eightChar.monthNaYin, eightChar.dayNaYin, eightChar.timeNaYin]
        timing.record("农历与八字基础数据", since: stepStart)

        stepStart = ProcessInfo.processInfo.systemUptime
        let pillars = PillarKind.allCases.indices.map { index in
            let ganzhi = ganzhis[index]
            return Pillar(
                kind: PillarKind.allCases[index],
                ganzhi: ganzhi,
                tenGod: ganGods[index],
                hidden: hideGans[index].map { HiddenStem(stem: stem(from: $0), tenGod: tenGod(dayGan: eightChar.dayGan, otherGan: $0)) },
                star: diShi[index],
                voidBranch: xunKong[index],
                nayin: naYin[index]
            )
        }
        timing.record("四柱与十神藏干", since: stepStart)

        stepStart = ProcessInfo.processInfo.systemUptime
        let currentYear = calendar.component(.year, from: targetDate)
        let currentAge = max(0, currentYear - calendar.component(.year, from: adjustedBirthDate) + 1)
        let yun = eightChar.getYun(gender: gender == .male ? 1 : 0, sect: 2)
        let daYun = yun.getDaYun(n: 11).filter { !$0.ganZhi.isEmpty }
        let luckColumns = daYun.map { item in
            let luckGanzhi = ganzhi(from: item.ganZhi)
            return LuckColumn(
                startYear: item.startYear,
                ageRange: "\(item.startAge)~\(item.endAge)岁",
                ganzhi: luckGanzhi,
                topTenGod: tenGod(dayGan: eightChar.dayGan, otherGan: String(item.ganZhi.prefix(1))),
                bottomTenGod: tenGod(dayGan: eightChar.dayGan, otherGan: firstHiddenGan(for: String(item.ganZhi.suffix(1)))),
                isCurrent: currentYear >= item.startYear && currentYear <= item.endYear
            )
        }
        timing.record("起运与大运", since: stepStart)

        stepStart = ProcessInfo.processInfo.systemUptime
        var annualFlowsByLuckStartYear: [Int: [FlowColumn]] = [:]

        for daYunItem in daYun {
            #if DEBUG
            for item in daYunItem.getLiuNian(n: 10) {
                assert(
                    item.ganZhi == yearGanzhi(forYear: item.year).text,
                    "流年干支快速路径与 lunar-swift 不一致：\(item.year)"
                )
            }
            #endif

            annualFlowsByLuckStartYear[daYunItem.startYear] = (0..<10).map { offset in
                let year = daYunItem.startYear + offset
                let gz = yearGanzhi(forYear: year)
                return FlowColumn(
                    title: "\(year)",
                    subtitle: year == currentYear ? "当前" : "",
                    date: dateBySetting(year: year, from: targetDate),
                    ganzhi: gz,
                    topTenGod: tenGod(dayGan: eightChar.dayGan, otherGan: gz.stem.rawValue),
                    bottomTenGod: tenGod(dayGan: eightChar.dayGan, otherGan: firstHiddenGan(for: gz.branch.rawValue))
                )
            }
        }
        timing.record("全部大运对应流年", since: stepStart)

        stepStart = ProcessInfo.processInfo.systemUptime
        let activeDaYun = daYun.first { currentYear >= $0.startYear && currentYear <= $0.endYear } ?? daYun.first
        let annualFlows = activeDaYun.flatMap { annualFlowsByLuckStartYear[$0.startYear] } ?? []
        let currentAnnualGanzhi = annualFlows.first { calendar.component(.year, from: $0.date) == currentYear }?.ganzhi
            ?? yearGanzhi(for: targetDate)
        let monthlyFlows = monthlyFlows(year: currentYear, annualGanzhi: currentAnnualGanzhi, dayGan: eightChar.dayGan)
        timing.record("当前流年与流月", since: stepStart)

        stepStart = ProcessInfo.processInfo.systemUptime
        let dailyFlows = dailyFlows(inMonthContaining: targetDate, dayGan: eightChar.dayGan)
        timing.record("当前月流日", since: stepStart)

        stepStart = ProcessInfo.processInfo.systemUptime
        let calibrationText = useTrueSolarTime
            ? trueSolarDescription(from: birthDate, longitude: longitude)
            : "未启用真太阳时，按标准北京时间排盘。"
        let solarDescription = birthDate.fullChineseDateTime
        let lunarDescription = lunar.description
        let luckStartText = "出生后\(yun.startYear)年\(yun.startMonth)月\(yun.startDay)天\(yun.startHour)小时起运，\(yun.forward ? "顺行" : "逆行")大运；当前约\(currentAge)岁。"
        let elementSummary = elementSummary(for: ganzhis)
        timing.record("描述文本与五行汇总", since: stepStart)

        stepStart = ProcessInfo.processInfo.systemUptime
        let chart = BaziChart(
            name: name.isEmpty ? "未命名" : name,
            gender: gender,
            birthDate: birthDate,
            adjustedBirthDate: adjustedBirthDate,
            targetDate: targetDate,
            locationName: locationName,
            longitude: longitude,
            useTrueSolarTime: useTrueSolarTime,
            calibrationText: calibrationText,
            sourceText: "6tail/lunar-swift，EightChar sect=2，起运 sect=2",
            solarDescription: solarDescription,
            lunarDescription: lunarDescription,
            dayMaster: dayMaster,
            pillars: pillars,
            luckStartText: luckStartText,
            luckColumns: luckColumns,
            annualFlows: annualFlows,
            monthlyFlows: monthlyFlows,
            dailyFlows: dailyFlows,
            annualFlowsByLuckStartYear: annualFlowsByLuckStartYear,
            elementSummary: elementSummary
        )
        timing.record("结果模型组装", since: stepStart)
        return (chart, timing)
    }

    static func monthlyFlows(year: Int, annualGanzhi: Ganzhi, dayGan: String) -> [FlowColumn] {
        let stems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
        let branches = ["寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥", "子", "丑"]
        let stemOffset: Int
        switch annualGanzhi.stem.rawValue {
        case "甲", "己": stemOffset = 2
        case "乙", "庚": stemOffset = 4
        case "丙", "辛": stemOffset = 6
        case "丁", "壬": stemOffset = 8
        default: stemOffset = 0
        }

        return (0..<12).compactMap { offset in
            let month = offset + 1
            let day = approximateTermDay(for: month)
            guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
                return nil
            }
            let ganzhiText = stems[(offset + stemOffset) % 10] + branches[offset]
            return FlowColumn(
                title: "\(month)月",
                subtitle: "\(month)/\(day)",
                date: date,
                ganzhi: ganzhi(from: ganzhiText),
                topTenGod: tenGod(dayGan: dayGan, otherGan: String(ganzhiText.prefix(1))),
                bottomTenGod: tenGod(dayGan: dayGan, otherGan: firstHiddenGan(for: String(ganzhiText.suffix(1))))
            )
        }
    }

    static func dailyFlows(around targetDate: Date, dayGan: String) -> [FlowDay] {
        dailyFlows(inMonthContaining: targetDate, dayGan: dayGan)
    }

    static func dailyFlows(inMonthContaining targetDate: Date, dayGan: String) -> [FlowDay] {
        let components = calendar.dateComponents([.year, .month], from: targetDate)
        guard let monthStart = calendar.date(from: DateComponents(year: components.year, month: components.month, day: 1)),
              let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        return dayRange.compactMap { day -> FlowDay? in
            guard let date = calendar.date(from: DateComponents(year: components.year, month: components.month, day: day)) else { return nil }
            let dailyLunar = solar(from: date).lunar
            let dailyGanzhiText = dailyLunar.dayInGanZhiExact2
            return FlowDay(
                date: date,
                ganzhi: ganzhi(from: dailyGanzhiText),
                topTenGod: tenGod(dayGan: dayGan, otherGan: String(dailyGanzhiText.prefix(1))),
                bottomTenGod: tenGod(dayGan: dayGan, otherGan: firstHiddenGan(for: String(dailyGanzhiText.suffix(1)))),
                lunarHint: dailyLunar.dayInChinese
            )
        }
    }

    private static func yearGanzhi(for date: Date) -> Ganzhi {
        let year = calendar.component(.year, from: date)
        let lichun = calendar.date(from: DateComponents(year: year, month: 2, day: 4, hour: 5)) ?? date
        return yearGanzhi(forYear: date < lichun ? year - 1 : year)
    }

    private static func solar(from date: Date) -> Solar {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return Solar.fromYmdHms(
            year: components.year ?? 2000,
            month: components.month ?? 1,
            day: components.day ?? 1,
            hour: components.hour ?? 0,
            minute: components.minute ?? 0,
            second: components.second ?? 0
        )
    }

    private static func trueSolarDate(from date: Date, longitude: Double) -> Date {
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let radians = 2.0 * Double.pi * Double(day - 81) / 364.0
        let equationOfTime = 9.87 * sin(2 * radians) - 7.53 * cos(radians) - 1.5 * sin(radians)
        let longitudeOffset = (longitude - 120.0) * 4.0
        return calendar.date(byAdding: .minute, value: Int(round(longitudeOffset + equationOfTime)), to: date) ?? date
    }

    private static func trueSolarDescription(from date: Date, longitude: Double) -> String {
        let corrected = trueSolarDate(from: date, longitude: longitude)
        let minutes = calendar.dateComponents([.minute], from: date, to: corrected).minute ?? 0
        return "启用真太阳时，经度\(String(format: "%.2f", longitude))°，校正\(minutes >= 0 ? "+" : "")\(minutes)分钟。"
    }

    private static func stem(from text: String) -> HeavenlyStem {
        HeavenlyStem.allCases.first { $0.rawValue == text } ?? .jia
    }

    private static func branch(from text: String) -> EarthlyBranch {
        EarthlyBranch.allCases.first { $0.rawValue == text } ?? .zi
    }

    private static func ganzhi(from text: String) -> Ganzhi {
        let chars = Array(text)
        guard chars.count >= 2 else { return Ganzhi(stem: .jia, branch: .zi) }
        return Ganzhi(stem: stem(from: String(chars[0])), branch: branch(from: String(chars[1])))
    }

    private static func tenGod(dayGan: String, otherGan: String) -> String {
        tenGod(from: stem(from: dayGan), to: stem(from: otherGan))
    }

    private static func firstHiddenGan(for branch: String) -> String {
        self.branch(from: branch).hiddenStems.first?.rawValue ?? branch
    }

    private static func yearGanzhi(forYear year: Int) -> Ganzhi {
        Ganzhi.at(year - 1984)
    }

    private static func dateBySetting(year: Int, from date: Date) -> Date {
        var components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
        components.year = year
        return calendar.date(from: components) ?? date
    }

    private static func dayGanzhi(for date: Date) -> Ganzhi {
        let start = calendar.startOfDay(for: date)
        let epoch = calendar.date(from: DateComponents(year: 1984, month: 2, day: 2)) ?? start
        let days = calendar.dateComponents([.day], from: epoch, to: start).day ?? 0
        return Ganzhi.at(days)
    }

    private static func hourGanzhi(for date: Date, dayStem: HeavenlyStem) -> Ganzhi {
        let hour = calendar.component(.hour, from: date)
        let branchIndex = ((hour + 1) / 2) % 12
        let ziStemStart: Int
        switch dayStem {
        case .jia, .ji: ziStemStart = HeavenlyStem.jia.index
        case .yi, .geng: ziStemStart = HeavenlyStem.bing.index
        case .bing, .xin: ziStemStart = HeavenlyStem.wu.index
        case .ding, .ren: ziStemStart = HeavenlyStem.geng.index
        case .wu, .gui: ziStemStart = HeavenlyStem.ren.index
        }
        return Ganzhi(
            stem: HeavenlyStem.allCases[(ziStemStart + branchIndex) % 10],
            branch: EarthlyBranch.allCases[branchIndex]
        )
    }

    static func tenGod(from dayMaster: HeavenlyStem, to stem: HeavenlyStem) -> String {
        let relation = elementRelation(day: dayMaster.element, other: stem.element)
        let samePolarity = dayMaster.polarity == stem.polarity
        switch relation {
        case .same: return samePolarity ? "比肩" : "劫财"
        case .dayCreates: return samePolarity ? "食神" : "伤官"
        case .dayControls: return samePolarity ? "偏财" : "正财"
        case .controlsDay: return samePolarity ? "七杀" : "正官"
        case .createsDay: return samePolarity ? "偏印" : "正印"
        }
    }

    private enum ElementRelation {
        case same
        case dayCreates
        case dayControls
        case controlsDay
        case createsDay
    }

    private static func elementRelation(day: FiveElement, other: FiveElement) -> ElementRelation {
        if day == other { return .same }
        if creates(day) == other { return .dayCreates }
        if controls(day) == other { return .dayControls }
        if controls(other) == day { return .controlsDay }
        return .createsDay
    }

    private static func creates(_ element: FiveElement) -> FiveElement {
        switch element {
        case .wood: .fire
        case .fire: .earth
        case .earth: .metal
        case .metal: .water
        case .water: .wood
        }
    }

    private static func controls(_ element: FiveElement) -> FiveElement {
        switch element {
        case .wood: .earth
        case .earth: .water
        case .water: .fire
        case .fire: .metal
        case .metal: .wood
        }
    }

    private static func luckDirection(gender: Gender, yearStem: HeavenlyStem) -> Int {
        let yangYear = yearStem.polarity == .yang
        return (gender == .male && yangYear) || (gender == .female && !yangYear) ? 1 : -1
    }

    private static func luckStartAge(from date: Date, direction: Int) -> Int {
        let comps = calendar.dateComponents([.month, .day, .hour], from: date)
        let month = comps.month ?? 1
        let day = comps.day ?? 1
        let nextGap = max(3, approximateTermDay(for: month) + 30 - day)
        let previousGap = max(3, day - approximateTermDay(for: month))
        let days = direction > 0 ? nextGap : previousGap
        return max(1, min(10, Int(round(Double(days) / 3.0))))
    }

    static func growthStage(dayMaster: HeavenlyStem, branch: EarthlyBranch) -> String {
        let stages = ["长生", "沐浴", "冠带", "临官", "帝旺", "衰", "病", "死", "墓", "绝", "胎", "养"]
        let start: EarthlyBranch
        switch dayMaster {
        case .jia: start = .hai
        case .yi: start = .wu
        case .bing: start = .yin
        case .ding: start = .you
        case .wu: start = .yin
        case .ji: start = .you
        case .geng: start = .si
        case .xin: start = .zi
        case .ren: start = .shen
        case .gui: start = .mao
        }
        let forward = dayMaster.polarity == .yang
        let distance = forward
            ? (branch.index - start.index + 12) % 12
            : (start.index - branch.index + 12) % 12
        return stages[distance]
    }

    private static func voidBranches(for ganzhi: Ganzhi) -> String {
        let groups = ["戌亥", "申酉", "午未", "辰巳", "寅卯", "子丑"]
        return groups[ganzhi.cycleIndex / 10]
    }

    private static func nayin(for ganzhi: Ganzhi) -> String {
        let names = [
            "海中金", "炉中火", "大林木", "路旁土", "剑锋金", "山头火", "涧下水", "城头土", "白蜡金", "杨柳木",
            "泉中水", "屋上土", "霹雳火", "松柏木", "长流水", "砂石金", "山下火", "平地木", "壁上土", "金箔金",
            "覆灯火", "天河水", "大驿土", "钗钏金", "桑柘木", "大溪水", "沙中土", "天上火", "石榴木", "大海水"
        ]
        return names[ganzhi.cycleIndex / 2]
    }

    private static func elementSummary(for ganzhis: [Ganzhi]) -> String {
        var counts = Dictionary(uniqueKeysWithValues: FiveElement.allCases.map { ($0, 0) })
        for ganzhi in ganzhis {
            counts[ganzhi.stem.element, default: 0] += 1
            counts[ganzhi.branch.element, default: 0] += 1
        }
        return FiveElement.allCases.map { "\($0.rawValue)\(counts[$0, default: 0])" }.joined(separator: "  ")
    }

    private static func monthName(_ month: Int) -> String {
        ["", "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"][month]
    }

    private static func approximateTermDay(for month: Int) -> Int {
        switch month {
        case 1: 6
        case 2: 4
        case 3: 6
        case 4: 5
        case 5: 6
        case 6: 6
        case 7: 7
        case 8: 8
        case 9: 8
        case 10: 8
        case 11: 7
        case 12: 7
        default: 1
        }
    }

    private static func lunarDayHint(for date: Date) -> String {
        let day = calendar.component(.day, from: date)
        let labels = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                      "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                      "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十", "初一"]
        return labels[min(max(day - 1, 0), labels.count - 1)]
    }
}

extension Date {
    var compactChineseDate: String {
        formatted(.dateTime.locale(Locale(identifier: "zh_CN")).year().month().day())
    }

    var fullChineseDateTime: String {
        formatted(.dateTime.locale(Locale(identifier: "zh_CN")).year().month().day().hour().minute())
    }
}
