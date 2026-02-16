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
                        // Our new custom progress bar
                        ProgressArch(progress: item.progressRatio, color: item.statusColor)
                        
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            Text("Expires in \(Calendar.current.dateComponents([.day], from: .now, to: item.expiryDate).day ?? 0) days")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
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
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddModal = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddModal) {
                AddReminderView { title, totalDays, expiryDate in
                    addItem(title: title, totalDays: totalDays, expiryDate: expiryDate)
                }
            }
        }
    }

    private func addItem(title: String, totalDays: Int, expiryDate: Date) {
        withAnimation {
            let newItem = Item(title: title, expiryDate: expiryDate, totalDays: totalDays)
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
