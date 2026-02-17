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
    
    var onSave: (String, Date, Date) -> Void

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
            }
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(title, startDate, expiryDate)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
