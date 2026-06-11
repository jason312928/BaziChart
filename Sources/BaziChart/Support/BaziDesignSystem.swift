import SwiftUI

enum BaziDesign {
    static let panelRadius: CGFloat = 22
    static let cardRadius: CGFloat = 16
    static let controlRadius: CGFloat = 11

    static let ink = Color(red: 0.06, green: 0.08, blue: 0.075)
    static let jade = Color(red: 0.12, green: 0.54, blue: 0.45)
    static let jadeBright = Color(red: 0.02, green: 0.86, blue: 0.72)
    static let cinnabar = Color(red: 0.78, green: 0.17, blue: 0.12)
    static let gold = Color(red: 0.78, green: 0.57, blue: 0.22)
    static let porcelain = Color(red: 0.60, green: 0.75, blue: 0.82)
    static let shadowBlue = Color(red: 0.12, green: 0.28, blue: 0.55)
    static let hairline = Color.primary.opacity(0.16)
    static let quickAnimation = Animation.easeOut(duration: 0.12)
    static let selectionAnimation = Animation.easeInOut(duration: 0.18)

    static let selectionGradient = LinearGradient(
        colors: [
            jadeBright.opacity(0.34),
            porcelain.opacity(0.17),
            gold.opacity(0.13)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardFill = LinearGradient(
        colors: [.white.opacity(0.035), .black.opacity(0.025)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func elementColor(_ element: FiveElement) -> Color {
        switch element {
        case .wood:
            Color(red: 0.15, green: 0.62, blue: 0.34)
        case .fire:
            Color(red: 0.86, green: 0.20, blue: 0.15)
        case .earth:
            Color(red: 0.69, green: 0.50, blue: 0.17)
        case .metal:
            Color(red: 0.86, green: 0.70, blue: 0.42)
        case .water:
            Color(red: 0.22, green: 0.50, blue: 0.88)
        }
    }

    static func elementGradient(_ element: FiveElement) -> LinearGradient {
        let color = elementColor(element)
        return LinearGradient(
            colors: [color.opacity(0.95), color.opacity(0.55)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension View {
    func premiumCard(cornerRadius: CGFloat = BaziDesign.cardRadius, active: Bool = false) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.black.opacity(active ? 0.15 : 0.09))
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    active ? BaziDesign.jadeBright.opacity(0.48) : BaziDesign.hairline,
                    lineWidth: active ? 1.4 : 1
                )
        }
    }

    func interactiveSurface(active: Bool, hovering: Bool, cornerRadius: CGFloat) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(active ? BaziDesign.selectionGradient : BaziDesign.cardFill)
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    active
                        ? BaziDesign.jadeBright.opacity(0.52)
                        : hovering
                            ? Color.primary.opacity(0.28)
                            : BaziDesign.hairline,
                    lineWidth: active ? 1.35 : 1
                )
        }
        .animation(BaziDesign.selectionAnimation, value: active)
        .animation(BaziDesign.quickAnimation, value: hovering)
    }
}

struct SurfaceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.82 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(BaziDesign.quickAnimation, value: configuration.isPressed)
    }
}

struct StatusPill: View {
    let text: String
    var systemImage: String?
    var color: Color = BaziDesign.jade

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .bold))
            }
            Text(text)
                .font(.caption.weight(.bold))
                .lineLimit(1)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(color.opacity(0.14), in: Capsule())
        .overlay {
            Capsule().stroke(color.opacity(0.28), lineWidth: 1)
        }
    }
}

struct ElementDot: View {
    let element: FiveElement
    var size: CGFloat = 9

    var body: some View {
        Circle()
            .fill(BaziDesign.elementGradient(element))
            .frame(width: size, height: size)
            .shadow(color: BaziDesign.elementColor(element).opacity(0.24), radius: 5)
    }
}

struct TermHint: ViewModifier {
    let term: String

    func body(content: Content) -> some View {
        if let explanation = BaziTerm.explanations[term] {
            content.help("\(term)：\(explanation)")
        } else {
            content
        }
    }
}

extension View {
    func termHint(_ term: String) -> some View {
        modifier(TermHint(term: term))
    }
}

enum BaziTerm {
    static let explanations: [String: String] = [
        "七杀": "克日主且阴阳相同，常看压力、竞争、执行与约束。",
        "正官": "克日主且阴阳相异，常看规则、秩序、名誉与责任。",
        "偏财": "日主所克且阴阳相同，常看外财、资源、机会与流动。",
        "正财": "日主所克且阴阳相异，常看稳定收入、现实关系与掌控。",
        "食神": "日主所生且阴阳相同，常看表达、产出、才艺与舒展。",
        "伤官": "日主所生且阴阳相异，常看锋芒、突破、表达与反规则。",
        "偏印": "生日主且阴阳相同，常看灵感、偏门知识、保护与不稳定支持。",
        "正印": "生日主且阴阳相异，常看学习、贵人、资质与稳定支持。",
        "比肩": "同日主且阴阳相同，常看自我、同辈、竞争与独立。",
        "劫财": "同日主且阴阳相异，常看争夺、合作、消耗与行动力。",
        "纳音": "六十甲子的音律五行，用于补充观察格局气象。",
        "空亡": "旬空位置，常用于观察落空、虚位或应期延迟。",
        "十二运": "五行生旺墓绝的阶段，用于观察气势强弱。",
        "神煞": "辅助参考符号，适合点到为止，不宜压过原局关系。",
        "桃花": "常看人缘、审美、情感吸引与社交显性。",
        "禄神": "常看根气、承载、资源与日主落点。",
        "驿马": "常看移动、变化、奔波与外部机会。",
        "根气": "日主在地支藏干中有根，代表承载与续航。"
    ]
}

extension BaziChart {
    var elementCounts: [(FiveElement, Int)] {
        FiveElement.allCases.map { element in
            let count = pillars.reduce(0) { partial, pillar in
                var value = partial
                if pillar.ganzhi.stem.element == element { value += 1 }
                if pillar.ganzhi.branch.element == element { value += 1 }
                return value
            }
            return (element, count)
        }
    }

    var strongestElement: FiveElement? {
        elementCounts.max { $0.1 < $1.1 }?.0
    }

    var missingElements: [FiveElement] {
        elementCounts.filter { $0.1 == 0 }.map(\.0)
    }

    var activeLuckColumn: LuckColumn? {
        luckColumns.first(where: \.isCurrent)
    }

    var insightPills: [String] {
        var items: [String] = []
        items.append("日主\(dayMaster.rawValue) \(dayMaster.element.rawValue)")
        if let strongestElement {
            items.append("\(strongestElement.rawValue)势最显")
        }
        if missingElements.isEmpty {
            items.append("五行俱全")
        } else {
            items.append("缺\(missingElements.map(\.rawValue).joined())")
        }
        if let activeLuckColumn {
            items.append("大运\(activeLuckColumn.ganzhi.text)")
        }
        return items
    }

    func relationshipBadges(for pillar: Pillar) -> [String] {
        guard let dayBranch = pillars.first(where: { $0.kind == .day })?.ganzhi.branch,
              pillar.kind != .day else {
            return pillar.kind == .day ? ["日主"] : []
        }
        let branch = pillar.ganzhi.branch
        var badges: [String] = []
        if branch.isSixHarmony(with: dayBranch) { badges.append("合") }
        if branch.isSixClash(with: dayBranch) { badges.append("冲") }
        if branch.isHarm(with: dayBranch) { badges.append("害") }
        if branch.isPunishment(with: dayBranch) { badges.append("刑") }
        if branch.isBreak(with: dayBranch) { badges.append("破") }
        return badges
    }
}

extension EarthlyBranch {
    func isSixHarmony(with other: EarthlyBranch) -> Bool {
        let pairs: Set<Set<EarthlyBranch>> = [
            [.zi, .chou], [.yin, .hai], [.mao, .xu], [.chen, .you], [.si, .shen], [.wu, .wei]
        ]
        return pairs.contains([self, other])
    }

    func isSixClash(with other: EarthlyBranch) -> Bool {
        let pairs: Set<Set<EarthlyBranch>> = [
            [.zi, .wu], [.chou, .wei], [.yin, .shen], [.mao, .you], [.chen, .xu], [.si, .hai]
        ]
        return pairs.contains([self, other])
    }

    func isHarm(with other: EarthlyBranch) -> Bool {
        let pairs: Set<Set<EarthlyBranch>> = [
            [.zi, .wei], [.chou, .wu], [.yin, .si], [.mao, .chen], [.shen, .hai], [.you, .xu]
        ]
        return pairs.contains([self, other])
    }

    func isBreak(with other: EarthlyBranch) -> Bool {
        let pairs: Set<Set<EarthlyBranch>> = [
            [.zi, .you], [.mao, .wu], [.chen, .chou], [.xu, .wei], [.yin, .hai], [.si, .shen]
        ]
        return pairs.contains([self, other])
    }

    func isPunishment(with other: EarthlyBranch) -> Bool {
        if self == other, [.chen, .wu, .you, .hai].contains(self) { return true }
        let pairs: Set<Set<EarthlyBranch>> = [
            [.yin, .si], [.si, .shen], [.shen, .yin], [.chou, .xu], [.xu, .wei], [.wei, .chou], [.zi, .mao]
        ]
        return pairs.contains([self, other])
    }
}

func elementColor(_ element: FiveElement) -> Color {
    BaziDesign.elementColor(element)
}
