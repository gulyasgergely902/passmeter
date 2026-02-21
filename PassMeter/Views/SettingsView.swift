//
//  Untitled.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 17..
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(
				header: Text("Notifications")
			) {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    NotificationManager.instance.scheduleTestNotification()
                } label: {
                    HStack {
                        Label("Test Alerts", systemImage: "bell.badge")
                        Spacer()
                        Text("Fire in 5s")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button("System Notification Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.footnote)
            }

			Section(
				header: Text("Icon")
			) {

			}

            Section(
				header: Text("About")
			) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
