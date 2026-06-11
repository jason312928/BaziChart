import SwiftUI
import AppKit

@main
struct BaziChartApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var store = DivinationStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("重新排盘") {
                    store.generate()
                }
                .keyboardShortcut(.return, modifiers: [.command])

                Button("复制完整排盘") {
                    store.copyResult()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])

                Button("保存当前档案") {
                    store.saveArchive()
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
        }

        Settings {
            SettingsView(store: store)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
