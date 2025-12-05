import SwiftUI

#if os(macOS)
import AppKit
#endif

@main
struct EmailStampApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .themed()
                #if os(macOS)
                .frame(minWidth: 1000, minHeight: 750)
                #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Email") {
                    NotificationCenter.default.post(name: .newEmail, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        #endif
    }
}
