//
//  AddPassView.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 16..
//

import SwiftUI
import SwiftData

struct AddPassView: View {
	@Environment(\.dismiss) private var dismiss

	let item: Item?

	@State private var title: String = ""
	@State private var startDate: Date = Date()
	@State private var expiryDate: Date = Date().addingTimeInterval(86400 * 30)
	@State private var hasEntryLimit: Bool = false
	@State private var totalEntries: Int = 10
	@State private var isNotificationEnabled: Bool = false
	@State private var reminderNotificationDate: Date = Date()

	var onSave: (String, Date, Date, Bool, Int, Bool, Date) -> Void

	init(item: Item? = nil, onSave: @escaping (String, Date, Date, Bool, Int, Bool, Date) -> Void) {
		self.item = item
		self.onSave = onSave
	}

	var body: some View {
		NavigationStack {
			Form {
				Section(
					header: Text("Pass Details"),
					footer: Text("Pass names cannot be edited after creation")
				) {
					TextField("Pass Name", text: $title)
				}
				Section("Timeline") {
					DatePicker(
						"Start Date",
						selection: $startDate,
						displayedComponents: .date)

					DatePicker(
						"Expiry Date",
						selection: $expiryDate,
						in: Date()...,
						displayedComponents: .date)
				}
				Section("Entry Count") {
					Toggle("Limited Entries", isOn: $hasEntryLimit)

					if hasEntryLimit {
						Stepper("Total Entries: \(totalEntries)", value: $totalEntries, in: 1...100)
					}
				}
				Section(
					header: Text("Expiry Reminder"),
					footer: Group {
						if isNotificationEnabled {
							Text("The app will notify you on \(reminderNotificationDate)")
						}
					}
				) {
					Toggle("Enable", isOn: $isNotificationEnabled)
					
					if isNotificationEnabled {
						DatePicker(
							"Select Date and Time",
							selection: $reminderNotificationDate,
							displayedComponents: [.date, .hourAndMinute]
						)
					}
				}
			}
			.onAppear {
				if let item = item {
					title = item.title
					startDate = item.startDate
					expiryDate = item.expiryDate
					hasEntryLimit = item.hasEntryLimit
					totalEntries = item.totalEntries
					isNotificationEnabled = item.isNotificationEnabled
					reminderNotificationDate = item.reminderNotificationDate
				}
			}
			.navigationTitle(item == nil ? "New Pass" : "Edit Pass")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						let generator = UIImpactFeedbackGenerator(style: .medium)
						generator.impactOccurred()
						dismiss()
					} label: {
						Image(systemName: "xmark")
							.fontWeight(.semibold)
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button{
						let generator = UINotificationFeedbackGenerator()
						generator.notificationOccurred(.success)
						onSave(title, startDate, expiryDate, hasEntryLimit, totalEntries, isNotificationEnabled, reminderNotificationDate)
						dismiss()
					} label: {
						Image(systemName: "checkmark")
							.fontWeight(.bold)
					}
					.disabled(title.isEmpty)
				}
			}
		}
	}
}
