//
//  ContentView.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 16..
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var isShowingAddModal = false
    @State private var selectedItem: Item?

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 12)

                            Circle()
                                .trim(from: 0, to: item.progressRatio.dateProgressRatio)
                                .stroke(
                                    item.statusDisplay.progressColor,
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                            if item.hasEntryLimit {
                                Circle()
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 8)
                                    .padding(14)

                                Circle()
                                    .trim(from: 0, to: item.progressRatio.entryProgressRatio)
                                    .stroke(
                                        item.entryCountProgressColor,
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .padding(14)
                                    .rotationEffect(.degrees(-90))
                            }
                        }
                        .frame(width: 45, height: 45)

                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)

                            Text(item.expiryDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(item.statusDisplay.statusText)
                                .foregroundColor(item.statusDisplay.textColor)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if item.hasEntryLimit {
                                Text("Remainin entries: \(item.remainingEntries)")
                                    .foregroundColor(item.statusDisplay.textColor)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        if item.hasEntryLimit && item.remainingEntries > 0 {
                            Button {
                                useEntry(for: item)
                            } label: {
                                Image(systemName: "ticket.fill")
                                    .font(.title3)
                                    .foregroundStyle(.green)
                                    .padding(8)
                                    .background(Color.green.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain) // Prevents the whole row from highlighting
                        }
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            selectedItem = item
                        } label: {
                            Label("Renew", systemImage: "arrow.clockwise")
                        }
                        .tint(.yellow)

                        Button {
                            print("TAP DETECTED")
                            deleteItems(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .navigationTitle("My Passes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
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
                AddReminderView { title, start, expiry, hasEntryLimit, totalEntries in
                    addItem(
                        title: title,
                        startDate: start,
                        expiryDate: expiry,
                        hasEntryLimit: hasEntryLimit,
                        totalEntries: totalEntries
                    )
                }
            }
            .sheet(item: $selectedItem) { itemToRenew in
                RenewPassView(item: itemToRenew)
                    .presentationDetents([.medium])
            }
            .onAppear {
                NotificationManager.instance.requestAuthorization()
            }
        }
    }

    private func addItem(title: String, startDate: Date, expiryDate: Date, hasEntryLimit: Bool = false, totalEntries: Int = 0) {
        print("AddItem")
        withAnimation {
            let newItem = Item(
                title: title,
                startDate: startDate,
                expiryDate: expiryDate,
                hasEntryLimit: hasEntryLimit,
                totalEntries: totalEntries
            )
            modelContext.insert(newItem)
            NotificationManager.instance.scheduleNotification(for: newItem)

            do {
                try modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                print("Failed to add pass: \(error)")
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
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if item.remainingEntries > 0 {
                item.remainingEntries -= 1
            }
        }

        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
