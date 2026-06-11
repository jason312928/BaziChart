import SwiftUI

struct ContentView: View {
    let store: DivinationStore
    @Namespace private var glassNamespace

    var body: some View {
        NavigationSplitView {
            InputSidebar(store: store)
                .navigationSplitViewColumnWidth(min: 360, ideal: 388, max: 440)
        } detail: {
            DetailWorkspace(store: store, glassNamespace: glassNamespace)
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 8) {
                    Button {
                        store.regenerateFromInput()
                    } label: {
                        Label("重新排盘", systemImage: "sparkles")
                    }
                    .keyboardShortcut(.return, modifiers: [.command])

                    Button {
                        store.saveArchive()
                    } label: {
                        Label("保存档案", systemImage: store.savedPulse ? "checkmark" : "archivebox")
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .keyboardShortcut("s", modifiers: [.command])

                    Button {
                        store.copyResult()
                    } label: {
                        Label("复制完整排盘", systemImage: store.copiedPulse ? "checkmark.circle.fill" : "doc.on.doc")
                            .contentTransition(.symbolEffect(.replace))
                            .scaleEffect(store.copiedPulse ? 1.04 : 1.0)
                    }
                    .disabled(store.chart == nil)
                    .keyboardShortcut("c", modifiers: [.command, .shift])
                    .animation(BaziDesign.selectionAnimation, value: store.copiedPulse)

                    Menu {
                        Button("前一日") { store.moveDailySelection(by: -1) }
                            .keyboardShortcut(.leftArrow, modifiers: [])
                        Button("后一日") { store.moveDailySelection(by: 1) }
                            .keyboardShortcut(.rightArrow, modifiers: [])
                        Divider()
                        Button("前一月") { store.moveMonthlySelection(by: -1) }
                            .keyboardShortcut(.leftArrow, modifiers: [.command])
                        Button("后一月") { store.moveMonthlySelection(by: 1) }
                            .keyboardShortcut(.rightArrow, modifiers: [.command])
                        Divider()
                        Button("前一流年") { store.moveAnnualSelection(by: -1) }
                            .keyboardShortcut(.leftArrow, modifiers: [.option])
                        Button("后一流年") { store.moveAnnualSelection(by: 1) }
                            .keyboardShortcut(.rightArrow, modifiers: [.option])
                        Divider()
                        Button("前一大运") { store.moveLuckSelection(by: -1) }
                            .keyboardShortcut(.leftArrow, modifiers: [.command, .option])
                        Button("后一大运") { store.moveLuckSelection(by: 1) }
                            .keyboardShortcut(.rightArrow, modifiers: [.command, .option])
                    } label: {
                        Label("切换焦点", systemImage: "arrow.left.arrow.right")
                    }
                }
            }
        }
        .frame(minWidth: 1280, minHeight: 820)
        .tint(.mint)
    }
}
