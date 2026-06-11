import Foundation
import Testing
@testable import BaziChart

@Suite("Bazi calculator")
struct BaziCalculatorTests {
    private let calendar = BaziCalculator.calendar

    @Test("Known chart produces stable four pillars")
    func knownChart() throws {
        let birthDate = try #require(
            calendar.date(from: DateComponents(year: 2024, month: 12, day: 18, hour: 11, minute: 38))
        )
        let targetDate = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 6, day: 10))
        )

        let chart = BaziCalculator.chart(
            name: "Test",
            gender: .male,
            birthDate: birthDate,
            targetDate: targetDate,
            locationName: "北京市 北京市 东城区",
            longitude: 116.40,
            useTrueSolarTime: true
        )

        #expect(chart.pillars.map(\.ganzhi.text) == ["甲辰", "丙子", "丙辰", "甲午"])
        #expect(chart.dayMaster == .bing)
        #expect(chart.monthlyFlows.count == 12)
        #expect(chart.dailyFlows.count == 30)
        #expect(chart.calibrationText.contains("校正-"))
    }

    @Test("Ten-god relationships cover same and opposing elements")
    func tenGodRelationships() {
        #expect(BaziCalculator.tenGod(from: .jia, to: .jia) == "比肩")
        #expect(BaziCalculator.tenGod(from: .jia, to: .yi) == "劫财")
        #expect(BaziCalculator.tenGod(from: .jia, to: .bing) == "食神")
        #expect(BaziCalculator.tenGod(from: .jia, to: .geng) == "七杀")
        #expect(BaziCalculator.tenGod(from: .jia, to: .gui) == "正印")
    }

    @Test("Location search supports names and administrative codes")
    func locationSearch() throws {
        let byName = LocationService.shared.search("广东 番禺")
        let byCode = LocationService.shared.search("110101")

        #expect(byName.first?.district == "番禺区")
        #expect(byCode.first?.displayName == "北京市 北京市 东城区")
        #expect(LocationService.shared.longitude(for: try #require(byCode.first)) == 116.40)
    }
}
