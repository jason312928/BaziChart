import SwiftUI

struct InputSidebar: View {
    @Bindable var store: DivinationStore
    @State private var archiveSearch = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SidebarSection(title: "命主", systemImage: "person.text.rectangle") {
                        TextField("姓名或备注", text: $store.name)
                            .textFieldStyle(.plain)
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 12)
                            .frame(height: 40)
                            .background(.black.opacity(0.11), in: RoundedRectangle(cornerRadius: BaziDesign.controlRadius, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: BaziDesign.controlRadius, style: .continuous)
                                    .stroke(.separator.opacity(0.22), lineWidth: 1)
                            }

                        GenderSwitch(selection: $store.gender)
                    }

                    SidebarSection(title: "时间", systemImage: "calendar.badge.clock") {
                        DatePartsControl(title: "出生", date: $store.birthDate, includesTime: true)
                        DatePartsControl(
                            title: "流盘",
                            date: $store.targetDate,
                            includesTime: false,
                            resetTitle: "今天",
                            resetAction: store.setTargetDateToToday
                        )
                    }

                    SidebarSection(title: "地区校准", systemImage: "location.viewfinder") {
                        TextField("搜索省 / 市 / 区县，例如 广东、番禺、闵行", text: $store.locationQuery)
                            .textFieldStyle(.plain)
                            .font(.callout.weight(.semibold))
                            .padding(.horizontal, 12)
                            .frame(height: 38)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 11, style: .continuous))

                        let locationResults = store.locationResults
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(locationResults.isEmpty ? "没有匹配地区" : "\(locationResults.count) 个匹配地区")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                if !store.locationQuery.isEmpty {
                                    Button("清除") {
                                        store.locationQuery = ""
                                    }
                                    .buttonStyle(.borderless)
                                    .font(.caption)
                                }
                            }

                            if !locationResults.isEmpty {
                                ScrollView {
                                    LazyVStack(spacing: 5) {
                                        ForEach(locationResults) { area in
                                            Button {
                                                store.selectArea(area)
                                            } label: {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(area.district)
                                                            .font(.callout.weight(.bold))
                                                        Text("\(area.province) / \(area.city)")
                                                            .font(.caption)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    Spacer()
                                                    Text(String(format: "%.2f°E", LocationService.shared.longitude(for: area)))
                                                        .font(.caption.weight(.semibold))
                                                        .foregroundStyle(.secondary)
                                                }
                                                .contentShape(Rectangle())
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 7)
                                                .background(
                                                    area.displayName == store.locationName
                                                        ? BaziDesign.jade.opacity(0.20)
                                                        : .black.opacity(0.08),
                                                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                )
                                            }
                                            .buttonStyle(SurfaceButtonStyle())
                                        }
                                    }
                                    .padding(.trailing, 3)
                                }
                                .frame(maxHeight: 230)
                            }
                        }

                        HStack(spacing: 10) {
                            Text("经度")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 42, alignment: .leading)
                            TextField("120.00", value: $store.longitude, format: .number.precision(.fractionLength(2)))
                                .textFieldStyle(.plain)
                                .font(.callout.weight(.semibold))
                                .padding(.horizontal, 10)
                                .frame(height: 34)
                                .background(.quaternary, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                            Text("E")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                        }

                        Toggle("真太阳时校正", isOn: $store.useTrueSolarTime)
                            .toggleStyle(.switch)

                        if let chart = store.chart {
                            SolarCalibrationCard(chart: chart)
                        }
                    }

                    if let chart = store.chart {
                        DayMasterCard(chart: chart)
                    }

                    SidebarSection(title: "档案", systemImage: "tray.full") {
                        if store.archives.isEmpty {
                            Text("暂无保存档案")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                        } else {
                            TextField("搜索档案", text: $archiveSearch)
                                .textFieldStyle(.plain)
                                .font(.callout.weight(.semibold))
                                .padding(.horizontal, 11)
                                .frame(height: 34)
                                .background(.black.opacity(0.10), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                            VStack(spacing: 6) {
                                ForEach(filteredArchives.prefix(6)) { profile in
                                    ArchiveRow(profile: profile) {
                                        store.loadArchive(profile)
                                    } delete: {
                                        store.deleteArchive(profile)
                                    }
                                }
                            }
                        }
                    }

                    if let validationMessage = store.validationMessage {
                        Label(validationMessage, systemImage: store.savedPulse ? "checkmark.circle.fill" : "info.circle")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(store.savedPulse ? .green : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(20)
            }

            VStack(spacing: 10) {
                Button {
                    store.regenerateFromInput()
                } label: {
                    Label(store.isCalculating ? "正在排盘" : "更新排盘", systemImage: store.isCalculating ? "hourglass" : "sparkles")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(BaziDesign.selectionGradient, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(BaziDesign.jadeBright.opacity(0.35), lineWidth: 1)
                        }
                }
                .buttonStyle(SurfaceButtonStyle())
                .controlSize(.large)
                .disabled(store.isCalculating)

                Button {
                    store.saveArchive()
                } label: {
                    Label(store.savedPulse ? "已保存" : "保存档案", systemImage: store.savedPulse ? "checkmark" : "archivebox")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(.black.opacity(0.13), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(BaziDesign.hairline, lineWidth: 1)
                        }
                }
                .buttonStyle(SurfaceButtonStyle())
                .controlSize(.large)
            }
            .padding(20)
            .background(.regularMaterial)
            .overlay(alignment: .top) { Divider().opacity(0.35) }
        }
        .onChange(of: store.name) { _, _ in store.requestGenerate(debounce: 0.24) }
        .onChange(of: store.gender) { _, _ in store.requestRegenerateFromInput(debounce: 0.04) }
        .onChange(of: store.birthDate) { _, _ in store.requestRegenerateFromInput(debounce: 0.18) }
        .onChange(of: store.targetDate) { _, _ in store.requestRegenerateFromInput(debounce: 0.14) }
        .onChange(of: store.longitude) { _, _ in store.requestRegenerateFromInput(debounce: 0.20) }
        .onChange(of: store.useTrueSolarTime) { _, _ in store.requestRegenerateFromInput(debounce: 0.04) }
    }

    private var filteredArchives: [SavedProfile] {
        let query = archiveSearch.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.archives }
        return store.archives.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || $0.locationName.localizedCaseInsensitiveContains(query)
                || $0.birthDate.fullChineseDateTime.localizedCaseInsensitiveContains(query)
        }
    }
}

private struct GenderSwitch: View {
    @Binding var selection: Gender
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Gender.allCases) { gender in
                Button {
                    withAnimation(BaziDesign.selectionAnimation) {
                        selection = gender
                    }
                } label: {
                    Text(gender.rawValue)
                        .font(.callout.weight(.bold))
                        .foregroundStyle(selection == gender ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background {
                            if selection == gender {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(BaziDesign.selectionGradient)
                                    .matchedGeometryEffect(id: "gender-selection", in: namespace)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(SurfaceButtonStyle())
            }
        }
        .padding(4)
        .background(.black.opacity(0.10), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(.separator.opacity(0.24), lineWidth: 1)
        }
    }
}

private struct SidebarSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary)

            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softGlass(cornerRadius: 18)
    }
}

private struct DatePartsControl: View {
    let title: String
    @Binding var date: Date
    let includesTime: Bool
    var resetTitle: String? = nil
    var resetAction: (() -> Void)? = nil

    private var calendar: Calendar {
        BaziCalculator.calendar
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                if let resetTitle, let resetAction {
                    Button(resetTitle, action: resetAction)
                        .buttonStyle(.borderless)
                        .font(.caption.weight(.bold))
                }
                Text(date.fullChineseDateTime)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            HStack(spacing: 6) {
                DatePartStepper(label: "年", value: binding(.year), range: 1900...2100, width: 48)
                DatePartStepper(label: "月", value: binding(.month), range: 1...12, width: 30)
                DatePartStepper(label: "日", value: binding(.day), range: 1...31, width: 30)
            }

            if includesTime {
                HStack(spacing: 6) {
                    Spacer(minLength: 0)
                    DatePartStepper(label: "时", value: binding(.hour), range: 0...23, width: 34)
                    DatePartStepper(label: "分", value: binding(.minute), range: 0...59, width: 34)
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(12)
        .background(.black.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.separator.opacity(0.20), lineWidth: 1)
        }
    }

    private func binding(_ component: Calendar.Component) -> Binding<Int> {
        Binding {
            calendar.component(component, from: date)
        } set: { newValue in
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            switch component {
            case .year:
                components.year = newValue
            case .month:
                components.month = newValue
            case .day:
                components.day = min(newValue, maxDay(year: components.year ?? 2000, month: components.month ?? 1))
            case .hour:
                components.hour = newValue
            case .minute:
                components.minute = newValue
            default:
                break
            }
            if let year = components.year, let month = components.month {
                components.day = min(components.day ?? 1, maxDay(year: year, month: month))
            }
            date = calendar.date(from: components) ?? date
        }
    }

    private func maxDay(year: Int, month: Int) -> Int {
        let start = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? date
        return calendar.range(of: .day, in: .month, for: start)?.count ?? 31
    }
}

private struct DatePartStepper: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let width: CGFloat

    var body: some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            HStack(spacing: 2) {
                Button {
                    value = value == range.lowerBound ? range.upperBound : value - 1
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 24, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(DateStepButtonStyle())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

                TextField(label, value: $value, format: .number)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .frame(width: width)
                    .contentTransition(.numericText())
                    .animation(BaziDesign.quickAnimation, value: value)
                    .onChange(of: value) { _, newValue in
                        value = min(max(newValue, range.lowerBound), range.upperBound)
                    }

                Button {
                    value = value == range.upperBound ? range.lowerBound : value + 1
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 24, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(DateStepButtonStyle())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 2)
            .frame(height: 34)
            .background(.black.opacity(0.14), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(BaziDesign.hairline, lineWidth: 1)
            }
        }
    }
}

private struct DateStepButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed ? BaziDesign.jadeBright.opacity(0.18) : .clear,
                in: RoundedRectangle(cornerRadius: 7, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(BaziDesign.quickAnimation, value: configuration.isPressed)
    }
}

private struct SolarCalibrationCard: View {
    let chart: BaziChart

    private var offsetMinutes: Double {
        ((chart.longitude - 120.0) * 4.0).rounded()
    }

    private var normalizedOffset: CGFloat {
        CGFloat(min(max((offsetMinutes + 32) / 64, 0), 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("真太阳时", systemImage: "sun.and.horizon")
                    .font(.caption.weight(.bold))
                Spacer()
                Text(offsetMinutes >= 0 ? "+\(Int(offsetMinutes)) 分钟" : "\(Int(offsetMinutes)) 分钟")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(BaziDesign.gold)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.black.opacity(0.16))
                    Capsule()
                        .fill(BaziDesign.selectionGradient)
                        .frame(width: max(8, proxy.size.width * normalizedOffset))
                    Circle()
                        .fill(BaziDesign.gold)
                        .frame(width: 9, height: 9)
                        .offset(x: max(0, proxy.size.width * normalizedOffset - 5))
                }
            }
            .frame(height: 8)

            Text(chart.calibrationText)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .premiumCard(cornerRadius: 12)
    }
}

private struct DayMasterCard: View {
    let chart: BaziChart

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Label("日主", systemImage: "sun.max")
                    .font(.headline)

            Text(chart.elementSummary)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                ElementMiniBars(chart: chart)
            }

            Spacer()

            Text(chart.dayMaster.rawValue)
                .font(.system(size: 54, weight: .bold, design: .serif))
                .foregroundStyle(elementColor(chart.dayMaster.element))

            Text(chart.dayMaster.element.rawValue)
                .font(.title3.weight(.bold))
        }
        .padding(16)
        .softGlass(cornerRadius: 22)
    }
}

private struct ElementMiniBars: View {
    let chart: BaziChart

    var body: some View {
        HStack(spacing: 5) {
            ForEach(chart.elementCounts, id: \.0) { element, count in
                VStack(spacing: 3) {
                    Capsule()
                        .fill(BaziDesign.elementGradient(element))
                        .frame(width: 8, height: CGFloat(8 + count * 6))
                    Text(element.rawValue)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .frame(height: 42, alignment: .bottom)
            }
        }
    }
}

private struct ArchiveRow: View {
    let profile: SavedProfile
    var load: () -> Void
    var delete: () -> Void
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 8) {
            Button(action: load) {
                HStack(spacing: 9) {
                    Circle()
                        .fill(BaziDesign.selectionGradient)
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(profile.title)
                            .font(.callout.weight(.semibold))
                            .lineLimit(1)
                        Text(profile.birthDate.fullChineseDateTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(SurfaceButtonStyle())

            Button(action: delete) {
                Image(systemName: "trash")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.borderless)
            .foregroundStyle(hovering ? .red.opacity(0.82) : .secondary.opacity(0.45))
            .opacity(hovering ? 1 : 0.55)
        }
        .padding(10)
        .background(.black.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(hovering ? Color.primary.opacity(0.24) : BaziDesign.hairline, lineWidth: 1)
        }
        .onHover { hovering = $0 }
        .animation(BaziDesign.quickAnimation, value: hovering)
    }
}
