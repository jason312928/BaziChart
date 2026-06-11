import SwiftUI

extension View {
    func softGlass(cornerRadius: CGFloat = 22, interactive: Bool = false) -> some View {
        modifier(SoftGlassModifier(cornerRadius: cornerRadius, interactive: interactive))
    }
}

private struct SoftGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var interactive: Bool

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *), interactive {
            content
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                }
        }
    }
}

extension Date {
    var compactChineseTime: String {
        formatted(.dateTime.locale(Locale(identifier: "zh_CN")).month().day().hour().minute())
    }

    var shortMonthDay: String {
        formatted(.dateTime.locale(Locale(identifier: "zh_CN")).month().day())
    }
}
