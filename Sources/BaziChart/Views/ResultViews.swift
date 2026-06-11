import SwiftUI

struct FourPillarsBoard: View {
    let chart: BaziChart

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            BoardTitle(title: "命盘", subtitle: "四柱 / 藏干 / 神煞")

            HStack(spacing: 12) {
                ForEach(chart.pillars) { pillar in
                    PillarCard(pillar: pillar, chart: chart)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .softGlass(cornerRadius: 22)
    }
}

private struct PillarCard: View {
    let pillar: Pillar
    let chart: BaziChart

    private var isDayPillar: Bool {
        pillar.kind == .day
    }

    var body: some View {
        VStack(spacing: 0) {
            PillarHeader(pillar: pillar, badges: chart.relationshipBadges(for: pillar), isDayPillar: isDayPillar)

            Text(pillar.tenGod)
                .font(.system(size: 17, weight: .bold))
                .frame(height: 44)
                .termHint(pillar.tenGod)

            PillarGlyphStack(pillar: pillar)

            Divider()

            HiddenStemStack(hidden: pillar.hidden)

            Divider()

            PillarMetaStack(pillar: pillar, dayMaster: chart.dayMaster)
        }
        .frame(minWidth: 0)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isDayPillar ? elementColor(chart.dayMaster.element).opacity(0.10) : .black.opacity(0.08))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isDayPillar ? elementColor(chart.dayMaster.element).opacity(0.55) : BaziDesign.hairline, lineWidth: isDayPillar ? 1.5 : 1)
        }
        .shadow(color: isDayPillar ? elementColor(chart.dayMaster.element).opacity(0.10) : .clear, radius: 8, y: 3)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct PillarHeader: View {
    let pillar: Pillar
    let badges: [String]
    let isDayPillar: Bool

    var body: some View {
        HStack {
            Text(pillar.kind.rawValue)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(isDayPillar ? .primary : .secondary)
            Spacer(minLength: 6)
            ForEach(badges, id: \.self) { badge in
                StatusPill(text: badge, color: badge == "冲" ? BaziDesign.cinnabar : BaziDesign.gold)
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background {
            if isDayPillar {
                BaziDesign.selectionGradient.opacity(0.70)
            } else {
                Color.primary.opacity(0.05)
            }
        }
    }
}

private struct PillarGlyphStack: View {
    let pillar: Pillar

    var body: some View {
        VStack(spacing: 2) {
            BigGanzhiGlyph(text: pillar.ganzhi.stem.rawValue, element: pillar.ganzhi.stem.element, size: 54)
                .frame(height: 66)
            BigGanzhiGlyph(text: pillar.ganzhi.branch.rawValue, element: pillar.ganzhi.branch.element, size: 54)
                .frame(height: 66)
        }
    }
}

private struct HiddenStemStack: View {
    let hidden: [HiddenStem]

    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                if index < hidden.count {
                    let item = hidden[index]
                    HStack(spacing: 3) {
                        Text(item.stem.rawValue)
                            .foregroundStyle(elementColor(item.stem.element))
                        Text(item.tenGod)
                            .foregroundStyle(.primary)
                            .termHint(item.tenGod)
                    }
                } else {
                    Text(" ")
                }
            }
        }
        .font(.system(size: 13, weight: .bold))
        .frame(height: 74)
    }
}

private struct PillarMetaStack: View {
    let pillar: Pillar
    let dayMaster: HeavenlyStem

    var body: some View {
        VStack(spacing: 0) {
            PillarMeta(label: "十二运", value: pillar.star)
            PillarMeta(label: "空亡", value: pillar.voidBranch)
            PillarMeta(label: "纳音", value: pillar.nayin)
            PillarMeta(label: "神煞", value: shensha(for: pillar, dayMaster: dayMaster), highlight: true)
        }
    }
}

private struct PillarMeta: View {
    let label: String
    let value: String
    var highlight = false

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 38, alignment: .leading)
            Text(value.replacingOccurrences(of: "\n", with: " / "))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(highlight ? .orange.opacity(0.9) : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .frame(maxWidth: .infinity, alignment: .leading)
                .termHint(value.components(separatedBy: "\n").first ?? value)
        }
        .padding(.horizontal, 10)
        .frame(height: 34)
        .overlay(alignment: .top) { Divider().opacity(0.45) }
    }
}

struct FlowBoard: View {
    let chart: BaziChart
    let store: DivinationStore
    @Namespace private var flowNamespace

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            FlowBoardHeader(chart: chart)
            LuckTimeline(
                columns: chart.luckColumns,
                selectedStartYear: store.selectedLuckStartYear,
                namespace: flowNamespace
            ) { column in
                store.selectLuck(column)
            }

            HStack(alignment: .top, spacing: 14) {
                FlowNavigatorPanel(chart: chart, store: store, namespace: flowNamespace)
                    .frame(width: 360)
                DayCalendarPanel(chart: chart, store: store, namespace: flowNamespace)
                    .frame(maxWidth: .infinity)
            }

            ElementSeasonRibbon()
        }
        .padding(16)
        .softGlass(cornerRadius: 22)
        .clipped()
    }
}

private struct FlowBoardHeader: View {
    let chart: BaziChart

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            BoardTitle(title: "运盘", subtitle: "大运定位 / 流年流月联动 / 流日整月选择")
            Spacer()
            StatusPill(text: chart.targetDate.compactChineseDate, systemImage: "calendar")
            StatusPill(text: "司令 \(chart.dayMaster.rawValue)", color: BaziDesign.gold)
        }
    }
}

private struct LuckTimeline: View {
    let columns: [LuckColumn]
    let selectedStartYear: Int?
    let namespace: Namespace.ID
    var select: (LuckColumn) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            FlowSectionHeader(title: "大运", subtitle: "十年一段，点击切换下方流年")

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(columns) { column in
                        Button {
                            select(column)
                        } label: {
                            LuckOrbitCard(
                                column: column,
                                active: selectedStartYear == column.startYear,
                                namespace: namespace
                            )
                        }
                        .buttonStyle(SurfaceButtonStyle())
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(12)
        .premiumCard(cornerRadius: 18)
        .clipped()
    }
}

private struct LuckOrbitCard: View {
    let column: LuckColumn
    let active: Bool
    let namespace: Namespace.ID
    @State private var hovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("\(column.startYear)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                if column.isCurrent {
                    Text("当前")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BaziDesign.gold)
                }
            }
            Text(column.ageRange)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer(minLength: 2)
            InlineGanzhi(ganzhi: column.ganzhi, size: 32)
            GodStack(top: column.topTenGod, bottom: column.bottomTenGod, size: 12, spacing: 3)
        }
        .padding(13)
        .frame(width: 132, height: 132, alignment: .leading)
        .interactiveSurface(active: active, hovering: hovering, cornerRadius: 16)
        .onHover { hovering = $0 }
        .animation(BaziDesign.selectionAnimation, value: active)
    }
}

private struct FlowNavigatorPanel: View {
    let chart: BaziChart
    let store: DivinationStore
    let namespace: Namespace.ID
    private var calendar: Calendar { BaziCalculator.calendar }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            FlowSectionHeader(title: "流年", subtitle: "当前大运内的十年")

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(store.visibleAnnualFlows) { column in
                        let active = store.selectedAnnualYear == calendar.component(.year, from: column.date)
                        Button {
                            store.selectAnnualFlow(column)
                        } label: {
                            FlowChipCard(column: column, active: active, compact: true)
                        }
                        .buttonStyle(SurfaceButtonStyle())
                    }
                }
                .padding(.vertical, 2)
            }

            FlowSectionHeader(title: "流月", subtitle: "节气月，选中后刷新右侧整月流日")
                .padding(.top, 2)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 3), spacing: 7) {
                ForEach(store.visibleMonthlyFlows) { column in
                    let active = isSameMonth(column.date, store.selectedMonthDate ?? chart.targetDate)
                    Button {
                        store.selectMonthlyFlow(column)
                    } label: {
                        FlowMonthTile(column: column, active: active, namespace: namespace)
                    }
                    .buttonStyle(SurfaceButtonStyle())
                }
            }

            SelectedFlowSummary(chart: chart, store: store)
        }
        .padding(12)
        .premiumCard(cornerRadius: 18)
        .clipped()
    }

    private func isSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.component(.year, from: lhs) == calendar.component(.year, from: rhs)
            && calendar.component(.month, from: lhs) == calendar.component(.month, from: rhs)
    }
}

private struct FlowChipCard: View {
    let column: FlowColumn
    let active: Bool
    var compact = false
    @State private var hovering = false

    var body: some View {
        VStack(spacing: compact ? 6 : 7) {
            Text(column.title)
                .font(.system(size: compact ? 16 : 18, weight: .bold, design: .rounded))
            if !column.subtitle.isEmpty {
                Text(column.subtitle)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(BaziDesign.gold)
            }
            InlineGanzhi(ganzhi: column.ganzhi, size: compact ? 25 : 29)
            GodStack(top: column.topTenGod, bottom: column.bottomTenGod, size: compact ? 11.5 : 12.5, spacing: 3)
        }
        .padding(.horizontal, compact ? 9 : 11)
        .padding(.vertical, 9)
        .frame(width: compact ? 88 : 104, height: compact ? 102 : 116)
        .interactiveSurface(active: active, hovering: hovering, cornerRadius: 15)
        .onHover { hovering = $0 }
        .animation(BaziDesign.selectionAnimation, value: active)
    }
}

private struct FlowMonthTile: View {
    let column: FlowColumn
    let active: Bool
    let namespace: Namespace.ID
    @State private var hovering = false

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(column.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Spacer()
                Text(column.subtitle)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            InlineGanzhi(ganzhi: column.ganzhi, size: 25)
            GodStack(top: column.topTenGod, bottom: column.bottomTenGod, size: 11.5, spacing: 2.5)
        }
        .padding(9)
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        .interactiveSurface(active: active, hovering: hovering, cornerRadius: 14)
        .onHover { hovering = $0 }
        .animation(BaziDesign.selectionAnimation, value: active)
    }
}

private struct DayCalendarPanel: View {
    let chart: BaziChart
    let store: DivinationStore
    let namespace: Namespace.ID
    private var calendar: Calendar { BaziCalculator.calendar }

    private var selectedMonthTitle: String {
        let date = store.selectedMonthDate ?? chart.targetDate
        return date.formatted(.dateTime.locale(Locale(identifier: "zh_CN")).year().month())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                FlowSectionHeader(title: "流日", subtitle: "整月日课，每一天都可选择")
                Spacer()
                StatusPill(text: selectedMonthTitle, systemImage: "calendar.day.timeline.left", color: BaziDesign.porcelain)
            }

            WeekdayHeader()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(0..<leadingBlankCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.clear)
                        .frame(height: 80)
                        .id("blank-\(index)")
                }

                ForEach(store.visibleDailyFlows) { day in
                    let active = calendar.isDate(day.date, inSameDayAs: store.selectedDayDate ?? chart.targetDate)
                    Button {
                        store.selectDailyFlow(day)
                    } label: {
                        DayCalendarTile(day: day, active: active, isToday: calendar.isDateInToday(day.date), namespace: namespace)
                    }
                    .buttonStyle(SurfaceButtonStyle())
                }
            }
        }
        .padding(12)
        .premiumCard(cornerRadius: 18)
        .clipped()
    }

    private var leadingBlankCount: Int {
        guard let firstDate = store.visibleDailyFlows.first?.date else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDate)
        return (weekday + 5) % 7
    }
}

private struct WeekdayHeader: View {
    private let days = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct DayCalendarTile: View {
    let day: FlowDay
    let active: Bool
    let isToday: Bool
    let namespace: Namespace.ID
    @State private var hovering = false
    private var calendar: Calendar { BaziCalculator.calendar }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(calendar.component(.day, from: day.date))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                if isToday {
                    Circle()
                        .fill(BaziDesign.gold)
                        .frame(width: 6, height: 6)
                }
            }

            Text(day.lunarHint)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            InlineGanzhi(ganzhi: day.ganzhi, size: 24)

            HStack(spacing: 4) {
                Text(day.topTenGod)
                Text(day.bottomTenGod)
            }
            .font(.caption2.weight(.bold))
            .foregroundStyle(BaziDesign.cinnabar)
            .lineLimit(1)
            .minimumScaleFactor(0.68)
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    active
                        ? BaziDesign.jadeBright.opacity(0.52)
                        : isToday
                            ? BaziDesign.gold.opacity(0.45)
                            : hovering
                                ? Color.primary.opacity(0.28)
                                : BaziDesign.hairline,
                    lineWidth: active ? 1.35 : 1
                )
        }
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(active ? BaziDesign.selectionGradient : BaziDesign.cardFill)
        }
        .onHover { hovering = $0 }
        .animation(BaziDesign.selectionAnimation, value: active)
        .animation(BaziDesign.quickAnimation, value: hovering)
    }
}

private struct FlowSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .serif))
            Text(subtitle)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}

private struct ElementSeasonRibbon: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(["金旺", "水相", "土休", "火囚", "木死"], id: \.self) { item in
                Text(item)
                    .font(.callout.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .foregroundStyle(.white.opacity(0.92))
        .padding(8)
        .background(BaziDesign.gold.opacity(0.52), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(BaziDesign.gold.opacity(0.34), lineWidth: 1)
        }
    }
}

private struct SelectedFlowSummary: View {
    let chart: BaziChart
    let store: DivinationStore
    private var calendar: Calendar { BaziCalculator.calendar }

    var body: some View {
        HStack(spacing: 10) {
            Label("当前焦点", systemImage: "scope")
                .font(.callout.weight(.bold))
                .foregroundStyle(.secondary)

            if let luck = chart.luckColumns.first(where: { $0.startYear == store.selectedLuckStartYear }) {
                StatusPill(text: "大运 \(luck.startYear) \(luck.ganzhi.text)", color: BaziDesign.jade)
            }
            if let year = store.selectedAnnualYear {
                StatusPill(text: "流年 \(year)", color: BaziDesign.porcelain)
            }
            if let month = store.selectedMonthDate {
                StatusPill(text: "流月 \(month.shortMonthDay)", color: BaziDesign.gold)
            }
            if let day = store.selectedDayDate {
                StatusPill(text: "流日 \(day.shortMonthDay)", color: BaziDesign.cinnabar)
            }

            Spacer()

            Text("方向键/点击可快速比较大运、流年、流月、流日")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(11)
        .premiumCard(cornerRadius: 14)
    }
}

private struct BoardTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .serif))
            Text(subtitle)
                .font(.callout.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}

private struct RowLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(width: 72)
    }
}

private struct BigGanzhiGlyph: View {
    let text: String
    let element: FiveElement
    let size: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .bold, design: .serif))
            .foregroundStyle(elementColor(element))
            .minimumScaleFactor(0.72)
    }
}

private struct InlineGanzhi: View {
    let ganzhi: Ganzhi
    let size: CGFloat

    var body: some View {
        HStack(spacing: 1) {
            Text(ganzhi.stem.rawValue)
                .foregroundStyle(elementColor(ganzhi.stem.element))
            Text(ganzhi.branch.rawValue)
                .foregroundStyle(elementColor(ganzhi.branch.element))
        }
        .font(.system(size: size, weight: .bold, design: .serif))
        .minimumScaleFactor(0.58)
        .lineLimit(1)
    }
}

private struct GodStack: View {
    let top: String
    let bottom: String
    var size: CGFloat = 13
    var spacing: CGFloat = 2

    var body: some View {
        VStack(spacing: spacing) {
            GodText(top)
            GodText(bottom)
        }
        .font(.system(size: size, weight: .bold))
        .lineLimit(1)
        .minimumScaleFactor(0.72)
    }
}

private struct GodText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        let warm = ["财", "才", "杀", "官", "印", "劫", "比"].contains { text.contains($0) }
        Text(text)
            .foregroundStyle(warm ? .red : .primary)
    }
}

struct ResultTextCard: View {
    let store: DivinationStore
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(BaziDesign.selectionAnimation) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "text.alignleft")
                    Text("复制文本预览")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
                .padding(16)
            }
            .buttonStyle(SurfaceButtonStyle())
            .accessibilityValue(isExpanded ? "已展开" : "已收起")

            if isExpanded, store.chart != nil {
                Divider()
                    .opacity(0.4)

                ScrollView {
                    Text(store.resultText)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                }
                .frame(minHeight: 220, maxHeight: 420)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .softGlass(cornerRadius: 18)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private func shensha(for pillar: Pillar, dayMaster: HeavenlyStem) -> String {
    var items: [String] = []
    if [.zi, .wu, .mao, .you].contains(pillar.ganzhi.branch) { items.append("桃花") }
    if [.yin, .shen, .si, .hai].contains(pillar.ganzhi.branch) { items.append("驿马") }
    if pillar.ganzhi.stem.element == dayMaster.element { items.append("禄神") }
    if pillar.ganzhi.branch.hiddenStems.contains(dayMaster) { items.append("根气") }
    if items.isEmpty { items = ["太极贵人", "天乙贵人"] }
    return items.joined(separator: "\n")
}
