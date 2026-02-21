//
//  ContentView.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 16..
//

import SwiftUI
import SwiftData
import WidgetKit
import ConfettiSwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var items: [Item]
	@State private var isShowingAddModal = false
	@State private var selectedItem: Item?
	@State private var itemToCheckIn: Item?
	@State private var itemForDetails: Item?
	@State private var isShowingConfirm = false

	@State private var confeTrigger = 0

	var body: some View {
		NavigationStack {
			ZStack {
				List {
					ForEach(items) { item in
						ListItem(item: item) { selectedItem in
							itemToCheckIn = selectedItem
							isShowingConfirm = true
						}
						.swipeActions(edge: .trailing, allowsFullSwipe: false) {
							Button {
								selectedItem = item
							} label: {
								Label("Renew", systemImage: "arrow.clockwise")
							}
							.tint(.yellow)

							Button {
								deleteItems(item)
							} label: {
								Label("Delete", systemImage: "trash")
							}
							.tint(.red)
						}
						.swipeActions(edge: .leading, allowsFullSwipe: false) {
							if item.hasEntryLimit && item.remainingEntries > 0 {
								Button {
									useEntry(for: item)
								} label: {
									Label("Check In", systemImage: "checkmark.circle.fill")
								}
								.tint(.blue)
							}
						}
						.onTapGesture {
							itemForDetails = item
						}
					}
				}
				.navigationTitle("My Passes")
				.toolbar {
					ToolbarItemGroup(placement: .topBarTrailing) {
						NavigationLink {
							SettingsView()
						} label: {
							Image(systemName: "gearshape")
						}

						Button(action: { isShowingAddModal = true }) {
							Image(systemName: "plus")
						}
					}
				}
				.sheet(isPresented: $isShowingAddModal) {
					AddPassView { title, start, expiry, hasEntryLimit, totalEntries, isNotificationEnabled, reminderNotificationDate in
						addItem(
							title: title,
							startDate: start,
							expiryDate: expiry,
							hasEntryLimit: hasEntryLimit,
							totalEntries: totalEntries,
							isNotificationEnabled: isNotificationEnabled,
							reminderNotificationDate: reminderNotificationDate
						)
					}.presentationDetents([.large])
				}
				.sheet(item: $selectedItem) { selectedItem in
					RenewPassView (item: selectedItem) { startDate, expiryDate, entryCount, isNotificationEnabled, reminderNotificationDate in
						renewItem(itemToRenew: selectedItem, startDate: startDate, expiryDate: expiryDate, entryCount: entryCount, isNotificationEnabled: isNotificationEnabled, reminderNotificationDate: reminderNotificationDate)
					}.presentationDetents([.large])
				}
				.sheet(item: $itemForDetails) { item in
					PassDetailsView(item: item)
				}
				.onAppear {
					NotificationManager.instance.requestAuthorization()
				}
				ConfettiCannon(
					trigger: $confeTrigger,
					confettiSize: 10,
					radius: 400
				)
			}
		}
	}

	private func addItem(title: String, startDate: Date, expiryDate: Date, hasEntryLimit: Bool = false, totalEntries: Int = 0, isNotificationEnabled: Bool = false, reminderNotificationDate: Date) {
		print("AddItem")
		withAnimation {
			let newItem = Item(
				title: title,
				startDate: startDate,
				expiryDate: expiryDate,
				hasEntryLimit: hasEntryLimit,
				totalEntries: totalEntries,
				isNotificationsEnabled: isNotificationEnabled,
				reminderNotificationDate: reminderNotificationDate
			)
			modelContext.insert(newItem)
			if isNotificationEnabled {
				NotificationManager.instance.scheduleNotification(for: newItem, reminderDate: reminderNotificationDate)
			}

			do {
				try modelContext.save()
				WidgetCenter.shared.reloadAllTimelines()
			} catch {
				print("Failed to add pass: \(error)")
			}
		}
	}

	private func renewItem(itemToRenew: Item, startDate: Date, expiryDate: Date, entryCount: Int, isNotificationEnabled: Bool = false, reminderNotificationDate: Date) {
		print("Renew Item")
		withAnimation{
			NotificationManager.instance.cancelNotification(for: itemToRenew)
			itemToRenew.startDate = startDate
			itemToRenew.expiryDate = expiryDate
			itemToRenew.totalEntries = entryCount
			itemToRenew.remainingEntries = entryCount
			itemToRenew.isNotificationEnabled = isNotificationEnabled
			itemToRenew.reminderNotificationDate = reminderNotificationDate
			if isNotificationEnabled {
				NotificationManager.instance.scheduleNotification(for: itemToRenew, reminderDate: reminderNotificationDate)
			}

			do {
				try modelContext.save()
				WidgetCenter.shared.reloadAllTimelines()
			} catch {
				print("Failed to save renewal: \(error)")
			}
		}
	}

	private func deleteItems(_ item: Item) {
		print("DeleteItems")
		withAnimation {
			print("Disabling notifications for \(item.title)")
			NotificationManager.instance.cancelNotification(for: item)
			print("Deleting item")
			modelContext.delete(item)
			print("Force refreshing widget")
			WidgetCenter.shared.reloadAllTimelines()
			print("Done")
		}
	}

	func useEntry(for item: Item) {
		confeTrigger += 1

		let generator = UINotificationFeedbackGenerator()
		generator.notificationOccurred(.success)

		withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
			if item.remainingEntries > 0 {
				item.remainingEntries -= 1
				item.entries.append(.now)
			}
		}

		try? modelContext.save()
		WidgetCenter.shared.reloadAllTimelines()
	}
}
