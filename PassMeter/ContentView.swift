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

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 12)

                            Circle()
                                .trim(from: 0, to: item.progressRatio)
                                .stroke(
                                    item.statusDisplay.progressColor,
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
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
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteItems)
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
                AddReminderView { title, start, end in
                    addItem(
                        title: title,
                        startDate: start,
                        expiryDate: end
                    )
                }
            }
            .onAppear {
                NotificationManager.instance.requestAuthorization()
            }
        }
    }

    private func addItem(title: String, startDate: Date, expiryDate: Date) {
        withAnimation {
            let newItem = Item(
                title: title,
                startDate: startDate,
                expiryDate: expiryDate
            )
            modelContext.insert(newItem)
            NotificationManager.instance.scheduleNotification(for: newItem)

            do {
                try modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                print("Failed to save pass: \(error)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = items[index]
                NotificationManager.instance.cancelNotification(for: item)
                modelContext.delete(item)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
