import SwiftUI

extension Notification.Name {
    static let myboardReload = Notification.Name("myboard.reload")
}

@main
struct MyBoardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1024, minHeight: 700)
        }
        // Barra de título nativa do macOS (arrastável, com os botões da janela).
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1280, height: 820)
        .commands {
            // Recarregar (⌘R) — comando nativo do app, não do browser.
            CommandGroup(after: .toolbar) {
                Button("Recarregar") {
                    NotificationCenter.default.post(name: .myboardReload, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
            }
            // App de janela única: remove "New Window" (⌘N).
            CommandGroup(replacing: .newItem) {}
        }
    }
}

struct ContentView: View {
    var body: some View {
        WebView()
            .ignoresSafeArea(edges: .bottom)
    }
}
