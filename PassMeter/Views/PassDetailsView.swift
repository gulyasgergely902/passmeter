//
//  PassDetailsView.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 20..
//

import SwiftUI
import SwiftData

struct PassDetailsView: View {
	let item: Item
	@Environment(\.dismiss) var dismiss

	var body: some View {
		NavigationStack {
			List {
				Section("Status") {
					LabeledContent("Expiration", value: item.expiryDate.formatted(date: .long, time: .omitted))
					if item.hasEntryLimit {
						LabeledContent("Entries", value: "\(item.remainingEntries) / \(item.totalEntries)")
						LabeledContent("Last Entry", value: item.entries.last?.formatted(date: .long, time: .omitted) ?? "No entries yet")
					}
				}
				if item.hasEntryLimit {
					Section("History") {
						ForEach(item.sortedEntries, id: \.self) { entry in
							HStack {
								Image(systemName: "calendar.badge.checkmark")
								Text(entry.formatted(date: .abbreviated, time: .shortened))
							}
						}
					}
				}
			}
			.navigationTitle(item.title)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				Button {
					dismiss()
				} label: {
					Image(systemName: "checkmark")
						.fontWeight(.bold)
				}
			}
		}
		.presentationDetents([.medium, .large])
		.presentationDragIndicator(.visible)
	}
}
