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
				Button("System Notification Settings") {
					if let url = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(url)
					}
				}
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
