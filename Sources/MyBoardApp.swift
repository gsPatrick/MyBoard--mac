import SwiftUI
import UserNotifications

extension Notification.Name {
    static let myboardReload = Notification.Name("myboard.reload")
}

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }

    // Mostra a notificação mesmo com o app em foco.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct MyBoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
