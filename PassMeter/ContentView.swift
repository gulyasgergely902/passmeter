//
//  ContentView.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 16..
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var isShowingAddModal = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    HStack(spacing: 20) {
                        ProgressArch(
                            progress: item.progressRatio,
                            color: item.statusDisplay.progressColor
                        )
                        
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
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = items[index]
                NotificationManager.instance.cancelNotification(for: item)
                modelContext.delete(item)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
