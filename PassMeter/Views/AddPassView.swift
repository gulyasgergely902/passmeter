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
    @State private var title: String = ""
    @State private var startDate: Date = Date()
    @State private var expiryDate: Date = Date().addingTimeInterval(86400 * 30)
    @State private var hasEntryLimit: Bool = false
    @State private var totalEntries: Int = 10
    @State private var isNotificationEnabled: Bool = false
    @State private var notificationOffsetDays: Int = 3

    var onSave: (String, Date, Date, Bool, Int, Bool, Int) -> Void

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
                        displayedComponents: .date)
                }
                Section("Entry Count") {
                    Toggle("Limited Entries", isOn: $hasEntryLimit)

                    if hasEntryLimit {
                        Stepper("Total Entries: \(totalEntries)", value: $totalEntries, in: 1...100)
                    }
                }
                Section(
                    header: Text("Expiry Notification"),
                    footer: Text("The app will notify you before the expiration offset by the number of days specified here at 9am.")
                ) {
                    Toggle("Enable Notifications", isOn: $isNotificationEnabled)
                    
                    if isNotificationEnabled {
                        Stepper("Days: \(notificationOffsetDays)", value: $notificationOffsetDays, in: 1...Utils.calculateMaxDays(from: .now, to: expiryDate))
                    }
                }
            }
            .navigationTitle("Add Pass")
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
                        onSave(title, startDate, expiryDate, hasEntryLimit, totalEntries, isNotificationEnabled, notificationOffsetDays)
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
