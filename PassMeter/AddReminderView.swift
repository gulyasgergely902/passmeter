//
//  AddReminderView.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 16..
//

import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var startDate: Date = Date()
    @State private var expiryDate: Date = Date().addingTimeInterval(86400 * 30)
    @State private var hasEntryLimit: Bool = false
    @State private var totalEntries: Int = 10

    var onSave: (String, Date, Date, Bool, Int) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Item Name", text: $title)
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
                Section("Usage Limit") {
                    Toggle("Limited Entries", isOn: $hasEntryLimit)

                    if hasEntryLimit {
                        Stepper("Total Entries: \(totalEntries)", value: $totalEntries, in: 1...100)
                    }
                }
            }
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(title, startDate, expiryDate, hasEntryLimit, totalEntries)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
