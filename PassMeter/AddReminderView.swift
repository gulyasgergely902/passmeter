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
    @State private var selectedDate: Date = Date().addingTimeInterval(86400 * 30) // Default to +30 days
    
    var onSave: (String, Int, Date) -> Void // Return title, totalDays, and the Date

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Item Name", text: $title)
                    
                    // The DatePicker
                    DatePicker(
                        "Expiry Date",
                        selection: $selectedDate,
                        in: Date()..., // Prevents selecting past dates
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical) // Gives a nice calendar view
                }
            }
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let total = calculateTotalDays(to: selectedDate)
                        onSave(title, total, selectedDate)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func calculateTotalDays(to date: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 1 // Default to 1 to avoid division by zero
    }
}
