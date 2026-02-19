//
//  PassMeterApp.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 16..
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct PassMeterApp: App {
    var sharedModelContainer: ModelContainer = {
        let groupID = "group.com.gergelygulyas.PassMeter"

        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)!
            .appendingPathComponent("PassMeter.sqlite")

        let config = ModelConfiguration(url: url)

        do {
            return try ModelContainer(for: Item.self, configurations: config)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
