import Foundation
import UserNotifications
import AppKit

/// Notificações nativas do macOS + badge no Dock.
enum NativeNotifications {
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    static func show(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    static func setBadge(_ count: Int) {
        DispatchQueue.main.async {
            NSApp.dockTile.badgeLabel = count > 0 ? String(count) : nil
        }
    }
}
