//
//  RenewPassView.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 18..
//

import SwiftUI
import SwiftData

struct RenewPassView: View {
	@Environment(\.dismiss) var dismiss

	let item: Item

	@State private var expiryDate: Date
	@State private var entryCount: Int
	@State private var isNotificationEnabled: Bool = false
	@State private var reminderNotificationDate: Date

	var onSave: (Date, Int, Bool, Date) -> Void

	init(item: Item, onSave: @escaping (Date, Int, Bool, Date) -> Void) {
		self.item = item
		self.onSave = onSave

		_expiryDate = State(initialValue: item.expiryDate)
		_entryCount = State(initialValue: item.totalEntries)
		_isNotificationEnabled = State(initialValue: item.isNotificationEnabled)
		_reminderNotificationDate = State(initialValue: item.reminderNotificationDate)
	}

	var body: some View {
		NavigationStack {
			Form {
				Section(
					header: Text("Timeline")
				) {
					HStack(spacing: 2) {
						Text(
							Date.now.formatted(date: .long, time: .omitted)
						)

						Spacer()

						Image(systemName: "arrow.right")
							.fontWeight(.bold)
							.foregroundColor(.gray)

						Spacer()

						DatePicker(
							"Expiry Date",
							selection: $expiryDate,
							in: Date()...,
							displayedComponents: .date
						)
						.labelsHidden()
					}
				}
				if item.hasEntryLimit {
					Section(
						header: Text("Entry Count"),
					) {
						Stepper("Total Entries: \(entryCount)", value: $entryCount, in: 1...100)
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
			.navigationTitle(item.title)
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
					Button {
						let generator = UINotificationFeedbackGenerator()
						generator.notificationOccurred(.success)
						onSave(expiryDate, entryCount, isNotificationEnabled, reminderNotificationDate)
						dismiss()
					} label: {
						Image(systemName: "checkmark")
							.fontWeight(.bold)
					}
				}
			}
		}
	}
}
