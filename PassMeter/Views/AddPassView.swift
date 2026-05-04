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
	@State private var remainingEntries: Int = 10
	@State private var totalEntries: Int = 10
	@State private var isNotificationEnabled: Bool = false
	@State private var reminderNotificationDate: Date = Date()

	var onSave: (String, Date, Date, Bool, Int, Int, Bool, Date) -> Void

	init(item: Item? = nil, onSave: @escaping (String, Date, Date, Bool, Int, Int, Bool, Date) -> Void) {
		self.item = item
		self.onSave = onSave
	}

	var body: some View {
		NavigationStack {
			Form {
				Section(
					header: Text("Pass Details"),
					footer: Text("Pass names cannot be edited after creation.")
				) {
					TextField("Pass Name", text: $title)
				}
				Section(
					header: Text("Timeline")
				) {
					HStack(spacing: 2) {
						DatePicker(
							"",
							selection: $startDate,
							displayedComponents: .date
						)
						.labelsHidden()

						Spacer()

						Image(systemName: "arrow.right")
							.fontWeight(.bold)
							.foregroundColor(.gray)

						Spacer()

						DatePicker(
							"",
							selection: $expiryDate,
							in: Date()...,
							displayedComponents: .date
						)
						.labelsHidden()
					}
				}
				Section(
					header: Text("Entry Count"),
					footer: Text("Limited-entry tracking, managed separately from expiration.")
				) {
					Toggle("Limited Entries", isOn: $hasEntryLimit.animation(.spring()))

					if hasEntryLimit {
						Picker("Total Entries", selection: $totalEntries) {
							ForEach(1...100, id: \.self) { number in
								Text("\(number)").tag(number)
							}
						}
						.pickerStyle(.wheel)
						.frame(height: 120)
						.transition(.move(edge: .top).combined(with: .opacity))
						if item != nil {
							Stepper(
								"Remaining Entries: \(remainingEntries)",
								value: $remainingEntries,
								in: 0...totalEntries
							)
							.transition(.move(edge: .top).combined(with: .opacity))
						}
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
					Toggle("Enable", isOn: $isNotificationEnabled.animation(.spring()))
					
					if isNotificationEnabled {
						DatePicker(
							"Select Date and Time",
							selection: $reminderNotificationDate,
							in: startDate...,
							displayedComponents: [.date, .hourAndMinute]
						)
						.transition(.move(edge: .top).combined(with: .opacity))
					}
				}
			}
			.onChange(of: startDate) { _, newStart in
				if reminderNotificationDate < newStart {
					reminderNotificationDate = newStart
				}
			}
			.onChange(of: totalEntries) { _, newTotalEntries in
				if remainingEntries > newTotalEntries {
					remainingEntries = newTotalEntries
				}
			}
			.onAppear {
				if let item = item {
					title = item.title
					startDate = item.startDate
					expiryDate = item.expiryDate
					hasEntryLimit = item.hasEntryLimit
					remainingEntries = item.remainingEntries
					totalEntries = item.totalEntries
					isNotificationEnabled = item.isNotificationEnabled
					reminderNotificationDate = item.reminderNotificationDate
				} else {
					remainingEntries = totalEntries
					reminderNotificationDate = expiryDate
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
						onSave(title, startDate, expiryDate, hasEntryLimit, remainingEntries, totalEntries, isNotificationEnabled, reminderNotificationDate)
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

#Preview {
	AddPassView(onSave: { _, _, _, _, _, _, _, _ in
		// Do nothing for the preview
	})
}
