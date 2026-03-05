//
//  PassDetailsView.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 20..
//

import SwiftUI
import SwiftData
import WidgetKit

struct PassDetailsView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss

	@State private var editedItem: Item?

	let item: Item

	var body: some View {
		NavigationStack {
			List {
				Section("Status") {
					LabeledContent("Expiration", value: item.expiryDate.formatted(date: .long, time: .omitted))
					LabeledContent("Notification", value: item.reminderNotificationDate.formatted(date: .long, time: .shortened))
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
				ToolbarItemGroup(placement: .topBarTrailing) {
					Button {
						editedItem = item
					} label: {
						Image(systemName: "square.and.pencil")
							.fontWeight(.bold)
					}
					Button {
						dismiss()
					} label: {
						Image(systemName: "checkmark")
							.fontWeight(.bold)
					}
				}
			}
			.sheet(item: $editedItem) { editedItem in
				AddPassView (item: editedItem) { title, startDate, expiryDate, hasEntryLimit, entryCount, isNotificationEnabled, reminderNotificationDate in
					editItem(itemToEdit: editedItem, title: title, startDate: startDate, expiryDate: expiryDate, hasEntryLimit: hasEntryLimit, entryCount: entryCount, isNotificationEnabled: isNotificationEnabled, reminderNotificationDate: reminderNotificationDate)
				}.presentationDetents([.large])
			}
		}
		.presentationDetents([.medium, .large])
		.presentationDragIndicator(.visible)
	}

	private func editItem(itemToEdit: Item, title: String, startDate: Date, expiryDate: Date, hasEntryLimit: Bool, entryCount: Int, isNotificationEnabled: Bool = false, reminderNotificationDate: Date) {
		withAnimation{
			NotificationManager.instance.cancelNotification(for: itemToEdit)
			itemToEdit.title = title
			itemToEdit.startDate = startDate
			itemToEdit.expiryDate = expiryDate
			itemToEdit.hasEntryLimit = hasEntryLimit
			itemToEdit.totalEntries = entryCount
			itemToEdit.remainingEntries = entryCount
			itemToEdit.isNotificationEnabled = isNotificationEnabled
			itemToEdit.reminderNotificationDate = reminderNotificationDate
			if isNotificationEnabled {
				NotificationManager.instance.scheduleNotification(for: itemToEdit, reminderDate: reminderNotificationDate)
			}

			do {
				try modelContext.save()
				WidgetCenter.shared.reloadAllTimelines()
			} catch {
				print("Failed to save renewal: \(error)")
			}
		}
	}
}
