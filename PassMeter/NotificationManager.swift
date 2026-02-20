//
//  NotificationManager.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 17..
//

import UserNotifications

@MainActor
class NotificationManager {
    static let instance = NotificationManager() // Singleton for easy access

    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            } else {
                print("SUCCESS: Notification permission granted.")
            }
        }
    }

    func scheduleNotification(for item: Item, offset: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Pass Expiring"
        content.body = "\(item.title)' is about to expire."
        content.sound = .default

        let calendar = Calendar.current
        let triggerDate = calendar.date(byAdding: .day, value: -offset, to: item.expiryDate) ?? item.expiryDate

        let components = calendar.dateComponents([.year, .month, .day], from: triggerDate)
        var scheduledComponents = components
        scheduledComponents.hour = 9
        scheduledComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: scheduledComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification 🔔"
        content.body = "This is a test to verify your PassMeter alerts are working!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: "TestNotificationID",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for item: Item) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
    }
}
