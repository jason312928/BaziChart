import Foundation
import SwiftUI
import Observation
#if canImport(AppKit)
import AppKit
#endif

@MainActor
@Observable
final class DivinationStore {
    var name = "命例"
    var gender: Gender = .male
    var birthDate: Date
    var targetDate: Date
    var locationQuery = "上海 闵行" {
        didSet {
            guard locationQuery != oldValue else { return }
            locationResults = LocationService.shared.search(locationQuery)
        }
    }
    var locationName = "上海市 上海市 闵行区"
    private(set) var locationResults: [AdministrativeArea] = []
    var longitude = 121.38
    var useTrueSolarTime = true
    var chart: BaziChart?
    var resultText = ""
    var calculationTiming = BaziCalculationTiming()
    var archives: [SavedProfile] = []
    private(set) var flowState = FlowState()
    var copiedPulse = false
    var savedPulse = false
    var isCalculating = false
    var validationMessage: String?

    private let archiveKey = "bazi.savedProfiles.v1"
    private let cacheLimit = 24
    private var generationTask: Task<Void, Never>?
    private var generationID = 0
    private var chartCache: [ChartRequest: BaziChart] = [:]
    private var textCache: [ChartRequest: String] = [:]
    private var timingCache: [ChartRequest: BaziCalculationTiming] = [:]
    private var cacheOrder: [ChartRequest] = []
    private var monthlyFlowCache: [Int: [FlowColumn]] = [:]
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        return calendar
    }

    var selectedLuckStartYear: Int? { flowState.selectedLuckStartYear }
    var selectedAnnualYear: Int? { flowState.selectedAnnualYear }
    var selectedMonthDate: Date? { flowState.selectedMonthDate }
    var selectedDayDate: Date? { flowState.selectedDayDate }
    var visibleAnnualFlows: [FlowColumn] { flowState.visibleAnnualFlows }
    var visibleMonthlyFlows: [FlowColumn] { flowState.visibleMonthlyFlows }
    var visibleDailyFlows: [FlowDay] { flowState.visibleDailyFlows }

    init() {
        var initialCalendar = Calendar(identifier: .gregorian)
        initialCalendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current
        birthDate = initialCalendar.date(from: DateComponents(year: 2008, month: 12, day: 18, hour: 11, minute: 38)) ?? Date()
        targetDate = Date()
        locationResults = LocationService.shared.search(locationQuery)
        loadArchives()
        generate()
    }

    func generate() {
        scheduleGeneration(resetSelection: false, debounce: 0)
    }

    func regenerateFromInput() {
        scheduleGeneration(resetSelection: true, debounce: 0)
    }

    func requestGenerate(debounce: TimeInterval = 0.18) {
        scheduleGeneration(resetSelection: false, debounce: debounce)
    }

    func requestRegenerateFromInput(debounce: TimeInterval = 0.18) {
        scheduleGeneration(resetSelection: true, debounce: debounce)
    }

    func setTargetDateToToday() {
        targetDate = Date()
    }

    func copyResult() {
        guard chart != nil else {
            validationMessage = "还没有生成排盘。"
            return
        }

        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resultText, forType: .string)
        #endif
        validationMessage = nil
        copiedPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.copiedPulse = false
        }
    }

    func saveArchive() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let profile = SavedProfile(
            id: UUID(),
            name: trimmedName.isEmpty ? "命例" : trimmedName,
            gender: gender,
            birthDate: birthDate,
            targetDate: targetDate,
            locationName: locationName,
            longitude: longitude,
            useTrueSolarTime: useTrueSolarTime,
            savedAt: Date()
        )
        archives.removeAll { $0.name == profile.name && calendar.isDate($0.birthDate, equalTo: profile.birthDate, toGranularity: .minute) }
        archives.insert(profile, at: 0)
        persistArchives()
        validationMessage = "已保存档案：\(profile.title)"
        savedPulse.toggle()
    }

    func loadArchive(_ profile: SavedProfile) {
        name = profile.name
        gender = profile.gender
        birthDate = profile.birthDate
        targetDate = profile.targetDate
        locationName = profile.locationName
        longitude = profile.longitude
        useTrueSolarTime = profile.useTrueSolarTime
        locationQuery = profile.locationName
        validationMessage = "已载入档案：\(profile.title)"
        regenerateFromInput()
    }

    func deleteArchive(_ profile: SavedProfile) {
        archives.removeAll { $0.id == profile.id }
        persistArchives()
    }

    func selectLuck(_ column: LuckColumn) {
        let annualFlows = annualFlows(startYear: column.startYear)
        let annualYear = annualFlows.first.map { calendar.component(.year, from: $0.date) }
        let monthlyFlows = annualYear.map { self.monthlyFlows(year: $0) } ?? []
        let monthDate = monthlyFlows.first?.date
        let dailyFlows = dailyFlows(around: monthDate ?? targetDate)
        flowState = FlowState(
            selectedLuckStartYear: column.startYear,
            selectedAnnualYear: annualYear,
            selectedMonthDate: monthDate,
            selectedDayDate: preferredDay(
                in: monthDate ?? targetDate,
                dailyFlows: dailyFlows,
                previousSelectedDay: flowState.selectedDayDate
            ),
            visibleAnnualFlows: annualFlows,
            visibleMonthlyFlows: monthlyFlows,
            visibleDailyFlows: dailyFlows
        )
    }

    func selectAnnualFlow(_ column: FlowColumn) {
        let year = calendar.component(.year, from: column.date)
        let monthlyFlows = monthlyFlows(year: year)
        let monthDate = monthlyFlows.first { calendar.isDate($0.date, equalTo: column.date, toGranularity: .month) }?.date
            ?? monthlyFlows.first?.date
        let dailyFlows = dailyFlows(around: monthDate ?? column.date)
        flowState = FlowState(
            selectedLuckStartYear: flowState.selectedLuckStartYear,
            selectedAnnualYear: year,
            selectedMonthDate: monthDate,
            selectedDayDate: preferredDay(
                in: monthDate ?? column.date,
                dailyFlows: dailyFlows,
                previousSelectedDay: flowState.selectedDayDate
            ),
            visibleAnnualFlows: flowState.visibleAnnualFlows,
            visibleMonthlyFlows: monthlyFlows,
            visibleDailyFlows: dailyFlows
        )
    }

    func selectMonthlyFlow(_ column: FlowColumn) {
        let dailyFlows = dailyFlows(around: column.date)
        let selectedDay = preferredDay(
            in: column.date,
            dailyFlows: dailyFlows,
            previousSelectedDay: flowState.selectedDayDate
        )
        flowState = FlowState(
            selectedLuckStartYear: flowState.selectedLuckStartYear,
            selectedAnnualYear: flowState.selectedAnnualYear,
            selectedMonthDate: column.date,
            selectedDayDate: selectedDay,
            visibleAnnualFlows: flowState.visibleAnnualFlows,
            visibleMonthlyFlows: flowState.visibleMonthlyFlows,
            visibleDailyFlows: dailyFlows
        )
    }

    func selectDailyFlow(_ day: FlowDay) {
        flowState.selectedDayDate = day.date
    }

    func moveDailySelection(by offset: Int) {
        guard !visibleDailyFlows.isEmpty else { return }
        let currentIndex = selectedDayDate.flatMap { selected in
            visibleDailyFlows.firstIndex { calendar.isDate($0.date, inSameDayAs: selected) }
        } ?? 0
        let proposedIndex = currentIndex + offset
        if proposedIndex < 0 {
            moveMonthlySelection(by: -1)
            flowState.selectedDayDate = visibleDailyFlows.last?.date
            return
        }
        if proposedIndex >= visibleDailyFlows.count {
            moveMonthlySelection(by: 1)
            flowState.selectedDayDate = visibleDailyFlows.first?.date
            return
        }
        let newIndex = proposedIndex
        selectDailyFlow(visibleDailyFlows[newIndex])
    }

    func moveMonthlySelection(by offset: Int) {
        guard !visibleMonthlyFlows.isEmpty else { return }
        let currentIndex = selectedMonthDate.flatMap { selected in
            visibleMonthlyFlows.firstIndex { calendar.isDate($0.date, equalTo: selected, toGranularity: .month) }
        } ?? 0
        let newIndex = min(max(currentIndex + offset, 0), visibleMonthlyFlows.count - 1)
        selectMonthlyFlow(visibleMonthlyFlows[newIndex])
    }

    func moveAnnualSelection(by offset: Int) {
        guard !visibleAnnualFlows.isEmpty else { return }
        let currentIndex = selectedAnnualYear.flatMap { selected in
            visibleAnnualFlows.firstIndex { calendar.component(.year, from: $0.date) == selected }
        } ?? 0
        let newIndex = min(max(currentIndex + offset, 0), visibleAnnualFlows.count - 1)
        selectAnnualFlow(visibleAnnualFlows[newIndex])
    }

    func moveLuckSelection(by offset: Int) {
        guard let chart, !chart.luckColumns.isEmpty else { return }
        let currentIndex = selectedLuckStartYear.flatMap { selected in
            chart.luckColumns.firstIndex { $0.startYear == selected }
        } ?? 0
        let newIndex = min(max(currentIndex + offset, 0), chart.luckColumns.count - 1)
        selectLuck(chart.luckColumns[newIndex])
    }

    func selectArea(_ area: AdministrativeArea) {
        locationName = area.displayName
        locationQuery = area.displayName
        longitude = LocationService.shared.longitude(for: area)
        regenerateFromInput()
    }

    private func loadArchives() {
        guard let data = UserDefaults.standard.data(forKey: archiveKey) else {
            archives = []
            return
        }
        archives = (try? JSONDecoder().decode([SavedProfile].self, from: data)) ?? []
    }

    private func persistArchives() {
        guard let data = try? JSONEncoder().encode(archives) else { return }
        UserDefaults.standard.set(data, forKey: archiveKey)
    }

    private func scheduleGeneration(resetSelection: Bool, debounce: TimeInterval) {
        generationTask?.cancel()
        generationID += 1
        let currentGenerationID = generationID
        let request = ChartRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            gender: gender,
            birthDate: birthDate,
            targetDate: targetDate,
            locationName: locationName,
            longitude: longitude,
            useTrueSolarTime: useTrueSolarTime
        )

        validationMessage = nil

        if let cachedChart = chartCache[request] {
            isCalculating = true
            chart = cachedChart
            resultText = textCache[request] ?? cachedChart.copyText
            calculationTiming = timingCache[request] ?? BaziCalculationTiming()
            monthlyFlowCache = [calendar.component(.year, from: cachedChart.targetDate): cachedChart.monthlyFlows]
            touchCache(request)
            syncSelection(resetSelection: resetSelection)
            isCalculating = false
            return
        }

        generationTask = Task.detached(priority: .userInitiated) { [request, currentGenerationID] in
            if debounce > 0 {
                try? await Task.sleep(for: .seconds(debounce))
                guard !Task.isCancelled else { return }
            }

            let shouldCalculate = await MainActor.run {
                guard currentGenerationID == self.generationID else { return false }
                self.isCalculating = true
                return true
            }
            guard shouldCalculate, !Task.isCancelled else { return }

            let calculation = BaziCalculator.chartWithTiming(
                name: request.name,
                gender: request.gender,
                birthDate: request.birthDate,
                targetDate: request.targetDate,
                locationName: request.locationName,
                longitude: request.longitude,
                useTrueSolarTime: request.useTrueSolarTime
            )
            guard !Task.isCancelled else { return }
            let textStart = ProcessInfo.processInfo.systemUptime
            let newResultText = calculation.chart.copyText
            var newTiming = calculation.timing
            newTiming.record("复制文本生成", since: textStart)

            await MainActor.run { [newResultText, newTiming] in
                guard currentGenerationID == self.generationID else { return }
                self.storeInCache(calculation.chart, text: newResultText, timing: newTiming, for: request)
                self.chart = calculation.chart
                self.resultText = newResultText
                self.calculationTiming = newTiming
                self.monthlyFlowCache = [self.calendar.component(.year, from: calculation.chart.targetDate): calculation.chart.monthlyFlows]
                self.syncSelection(resetSelection: resetSelection)
                self.isCalculating = false
            }
        }
    }

    private func storeInCache(_ chart: BaziChart, text: String, timing: BaziCalculationTiming, for request: ChartRequest) {
        chartCache[request] = chart
        textCache[request] = text
        timingCache[request] = timing
        touchCache(request)

        while cacheOrder.count > cacheLimit {
            let oldest = cacheOrder.removeFirst()
            chartCache.removeValue(forKey: oldest)
            textCache.removeValue(forKey: oldest)
            timingCache.removeValue(forKey: oldest)
        }
    }

    private func touchCache(_ request: ChartRequest) {
        cacheOrder.removeAll { $0 == request }
        cacheOrder.append(request)
    }

    private func syncSelection(resetSelection: Bool) {
        guard let chart else { return }
        let targetYear = calendar.component(.year, from: targetDate)
        let luckStartYear = resetSelection ? nil : flowState.selectedLuckStartYear
        let annualYear = resetSelection ? nil : flowState.selectedAnnualYear
        let monthDate = resetSelection ? nil : flowState.selectedMonthDate
        let dayDate = resetSelection ? nil : flowState.selectedDayDate

        let resolvedLuckStartYear = luckStartYear
            ?? chart.luckColumns.first { targetYear >= $0.startYear && targetYear < $0.startYear + 10 }?.startYear
        let resolvedAnnualYear = annualYear ?? targetYear
        let resolvedMonthDate = monthDate
            ?? chart.monthlyFlows.first { calendar.isDate($0.date, equalTo: targetDate, toGranularity: .month) }?.date
        let resolvedDayDate = dayDate
            ?? chart.dailyFlows.first { calendar.isDate($0.date, inSameDayAs: targetDate) }?.date
        let annualFlows = resolvedLuckStartYear.map { self.annualFlows(startYear: $0) } ?? chart.annualFlows
        let monthlyFlows = monthlyFlows(year: resolvedAnnualYear)
        let dailyFlows = dailyFlows(around: resolvedMonthDate ?? targetDate)

        flowState = FlowState(
            selectedLuckStartYear: resolvedLuckStartYear,
            selectedAnnualYear: resolvedAnnualYear,
            selectedMonthDate: resolvedMonthDate,
            selectedDayDate: resolvedDayDate,
            visibleAnnualFlows: annualFlows,
            visibleMonthlyFlows: monthlyFlows,
            visibleDailyFlows: dailyFlows
        )
    }

    private func annualFlows(startYear: Int) -> [FlowColumn] {
        guard let chart else { return [] }
        return chart.annualFlowsByLuckStartYear[startYear] ?? []
    }

    private func monthlyFlows(year: Int) -> [FlowColumn] {
        guard let chart else { return [] }
        if let cached = monthlyFlowCache[year] {
            return cached
        }
        guard let annualFlow = chart.annualFlowsByLuckStartYear.values
            .lazy
            .flatMap({ $0 })
            .first(where: { calendar.component(.year, from: $0.date) == year }) else {
            return []
        }
        let flows = BaziCalculator.monthlyFlows(
            year: year,
            annualGanzhi: annualFlow.ganzhi,
            dayGan: chart.dayMaster.rawValue
        )
        monthlyFlowCache[year] = flows
        return flows
    }

    private func dailyFlows(around date: Date) -> [FlowDay] {
        guard let chart else { return [] }
        return BaziCalculator.dailyFlows(inMonthContaining: date, dayGan: chart.dayMaster.rawValue)
    }

    private func preferredDay(in monthDate: Date, dailyFlows: [FlowDay], previousSelectedDay: Date?) -> Date? {
        if calendar.isDate(targetDate, equalTo: monthDate, toGranularity: .month),
           let targetDay = dailyFlows.first(where: { calendar.isDate($0.date, inSameDayAs: targetDate) }) {
            return targetDay.date
        }
        if let previousSelectedDay,
           calendar.isDate(previousSelectedDay, equalTo: monthDate, toGranularity: .month),
           let selectedDay = dailyFlows.first(where: { calendar.isDate($0.date, inSameDayAs: previousSelectedDay) }) {
            return selectedDay.date
        }
        return dailyFlows.first?.date
    }
}

struct FlowState {
    var selectedLuckStartYear: Int?
    var selectedAnnualYear: Int?
    var selectedMonthDate: Date?
    var selectedDayDate: Date?
    var visibleAnnualFlows: [FlowColumn] = []
    var visibleMonthlyFlows: [FlowColumn] = []
    var visibleDailyFlows: [FlowDay] = []
}

private struct ChartRequest: Hashable, Sendable {
    let name: String
    let gender: Gender
    let birthDate: Date
    let targetDate: Date
    let locationName: String
    let longitude: Double
    let useTrueSolarTime: Bool
}
