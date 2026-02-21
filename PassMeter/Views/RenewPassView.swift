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

	@State private var startDate: Date
    @State private var expiryDate: Date
    @State private var entryCount: Int
    @State private var isNotificationEnabled: Bool = false
    @State private var notificationOffsetDays: Int = 3

    var onSave: (Date, Date, Int, Bool, Int) -> Void

    init(item: Item, onSave: @escaping (Date, Date, Int, Bool, Int) -> Void) {
        self.item = item
        self.onSave = onSave

		_startDate = State(initialValue: item.startDate)
        _expiryDate = State(initialValue: item.expiryDate)
        _entryCount = State(initialValue: item.totalEntries)
        _isNotificationEnabled = State(initialValue: item.isNotificationEnabled)
        _notificationOffsetDays = State(initialValue: item.notificationOffsetDays)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("Pass Details"),
                    footer: Text("Pass names cannot be edited after creation")
                ) {
                    LabeledContent("Pass Name", value: item.title)
                }
                Section(
                    header: Text("Timeline")
                ) {
					DatePicker(
						"Start Date",
						selection: $startDate,
						displayedComponents: .date
					)
                    DatePicker(
                        "Expiry Date",
                        selection: $expiryDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                }
                if item.hasEntryLimit {
                    Section(
                        header: Text("Entry Count"),
                    ) {
                        Stepper("Total Entries: \(entryCount)", value: $entryCount, in: 1...100)
                    }
                }
                Section(
                    header: Text("Expiry Notification"),
					footer: Group {
						if isNotificationEnabled {
							Text("The app will notify you on \(Utils.calculateDateBeforeDays(date: expiryDate, days: notificationOffsetDays) ?? Date.now, format: .dateTime.month().day().year()) at 9am.")
						}
					}
                ) {
                    Toggle("Enable Notifications", isOn: $isNotificationEnabled)

                    if isNotificationEnabled {
                        Stepper("Days: \(notificationOffsetDays)", value: $notificationOffsetDays, in: 1...Utils.calculateMaxDays(from: .now, to: expiryDate))
                    }
                }
            }
            .navigationTitle("Renew Pass")
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
                        onSave(startDate, expiryDate, entryCount, isNotificationEnabled, notificationOffsetDays)
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
