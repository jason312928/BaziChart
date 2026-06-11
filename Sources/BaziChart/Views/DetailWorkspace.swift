import SwiftUI

struct DetailWorkspace: View {
    let store: DivinationStore
    var glassNamespace: Namespace.ID

    var body: some View {
        ZStack {
            AppBackdrop()

            ScrollView(.vertical) {
                if let chart = store.chart {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ChartHeader(chart: chart)
                            .glassEffectID("header", in: glassNamespace)

                        FourPillarsBoard(chart: chart)
                            .frame(maxWidth: .infinity)

                        FlowBoard(chart: chart, store: store)
                            .frame(maxWidth: .infinity)

                        ResultTextCard(store: store)
                            .frame(maxWidth: .infinity)

                    }
                    .padding(22)
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .top)

            if store.isCalculating {
                VStack {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("正在排盘")
                            .font(.caption.weight(.bold))
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(.regularMaterial, in: Capsule())
                    .overlay {
                        Capsule().stroke(BaziDesign.jadeBright.opacity(0.28), lineWidth: 1)
                    }
                    Spacer()
                }
                .padding(.top, 18)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .allowsHitTesting(false)
            }
        }
        .animation(BaziDesign.selectionAnimation, value: store.isCalculating)
    }
}

private struct AppBackdrop: View {
    var body: some View {
        ZStack {
            BaziDesign.ink
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.55, 0.45], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    BaziDesign.jade.opacity(0.24), BaziDesign.porcelain.opacity(0.10), .gray.opacity(0.08),
                    BaziDesign.shadowBlue.opacity(0.14), .clear, BaziDesign.gold.opacity(0.09),
                    BaziDesign.jade.opacity(0.12), BaziDesign.shadowBlue.opacity(0.10), BaziDesign.cinnabar.opacity(0.05)
                ]
            )
            .opacity(0.92)

            LinearGradient(
                colors: [.black.opacity(0.16), .clear, .black.opacity(0.22)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

private struct ChartHeader: View {
    let chart: BaziChart

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text(chart.name)
                    .font(.system(size: 30, weight: .bold, design: .serif))
                Text("\(chart.gender.rawValue)  出生 \(chart.solarDescription)")
                    .foregroundStyle(.secondary)
                Text(chart.luckStartText)
                    .foregroundStyle(.secondary)

                HStack(spacing: 7) {
                    ForEach(chart.insightPills, id: \.self) { item in
                        StatusPill(text: item, color: item.contains("缺") ? BaziDesign.gold : BaziDesign.jade)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text("日主 \(chart.dayMaster.rawValue)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(elementColor(chart.dayMaster.element))
                ElementBalanceStrip(chart: chart)
            }
        }
        .padding(18)
        .softGlass(cornerRadius: 22)
    }
}

private struct ElementBalanceStrip: View {
    let chart: BaziChart

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(chart.elementCounts, id: \.0) { element, count in
                VStack(spacing: 4) {
                    Text("\(count)")
                        .font(.caption.weight(.bold))
                    Capsule()
                        .fill(BaziDesign.elementGradient(element))
                        .frame(width: 11, height: CGFloat(12 + count * 8))
                    Text(element.rawValue)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .premiumCard(cornerRadius: 13)
        .help(chart.elementSummary)
    }
}
