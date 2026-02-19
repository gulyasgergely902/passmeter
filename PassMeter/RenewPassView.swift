//
//  RenewPassView.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 18..
//

import SwiftUI
import SwiftData
import WidgetKit

struct RenewPassView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Renewal Details")) {
                    LabeledContent("Pass Name", value: item.title)

                    DatePicker(
                        "New Expiry Date",
                        selection: $item.expiryDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                }
                if item.hasEntryLimit {
                    Section("Entry Refill") {
                        Stepper("Total Entries: \(item.totalEntries)", value: $item.totalEntries, in: 1...100)
                        Text("This will reset your remaining entries to \(item.totalEntries).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Renew Pass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let design = UINotificationFeedbackGenerator()
                        design.notificationOccurred(.success)

                        item.startDate = .now
                        if item.hasEntryLimit {
                            item.remainingEntries = item.totalEntries
                        }
                        WidgetCenter.shared.reloadAllTimelines()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}
