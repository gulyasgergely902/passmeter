//
//  PassMeterWidget.swift
//  PassMeterWidget
//
//  Created by Gulyas Gergely on 2026. 02. 17..
//

import WidgetKit
import SwiftUI
import SwiftData

struct WidgetItem: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let expiryDate: Date
    let progress: Double
    let isExpired: Bool
    let progressColor: Color
    let statusText: String
    let textColor: Color
}

struct WidgetItemsList: TimelineEntry {
    let date: Date
    let items: [WidgetItem]
}

let mockWidget = WidgetItem(
    date: .now,
    title: "N/A",
    expiryDate: .distantFuture,
    progress: 0.0,
    isExpired: false,
    progressColor: .gray,
    statusText: "N/A",
    textColor: .gray
)

struct Provider: TimelineProvider {
    typealias Entry = WidgetItemsList

    @MainActor
    func fetchItems() -> [WidgetItem] {
        let mockItemList: Array<WidgetItem> = [mockWidget, mockWidget]
        let groupID = "group.com.gergelygulyas.PassMeter"

        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return mockItemList
        }

        let url = containerURL.appendingPathComponent("PassMeter.sqlite")
        let config = ModelConfiguration(url: url)

        do {
            let container = try ModelContainer(for: Item.self, configurations: config)
            let descriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\.expiryDate)])
            let allItems = try container.mainContext.fetch(descriptor)

            return allItems.prefix(2).map { item in
                WidgetItem(
                    date: .now,
                    title: item.title,
                    expiryDate: item.expiryDate,
                    progress: item.progressRatio,
                    isExpired: item.isExpired,
                    progressColor: item.statusDisplay.progressColor,
                    statusText: item.statusDisplay.statusText,
                    textColor: item.statusDisplay.textColor
                )
            }
        } catch {
            return mockItemList
        }
    }

    func placeholder(in context: Context) -> WidgetItemsList {
        let sampleWidget = WidgetItem(
            date: .now,
            title: "Sample Pass",
            expiryDate: .distantFuture,
            progress: 0.7,
            isExpired: false,
            progressColor: .blue,
            statusText: "Sample Status",
            textColor: .blue
        )
        return WidgetItemsList(
            date: .now,
            items: [
                sampleWidget,
                sampleWidget
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetItemsList) -> ()) {
        Task { @MainActor in
            let items = fetchItems()
            let entry = WidgetItemsList(date: .now, items: items)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetItemsList>) -> ()) {
        Task { @MainActor in
            let items = fetchItems()
            let entry = WidgetItemsList(date: .now, items: items)
            let timeline = Timeline(entries: [entry], policy: .atEnd)

            completion(timeline)
        }
    }
}

struct SmallWidgetView: View {
    let item: WidgetItem

    var body: some View {
        VStack{
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .lineLimit(2)

                Text(item.expiryDate, style: .date)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)

                Text(item.statusText)
                    .foregroundColor(item.textColor)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
                Spacer()
                Text("")
            }
            Spacer()

            HStack {
                Text("")
                Spacer()
                ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 14)

                Circle()
                    .trim(from: 0, to: item.progress)
                    .stroke(
                        item.progressColor,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 55, height: 55)
            }
        }.containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MediumWidgetView: View {
    let items: [WidgetItem]

    var body: some View {
        VStack {
            ForEach(Array(zip(items.indices, items)), id: \.1.id) { index, item in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .lineLimit(2)

                        Text(item.expiryDate, style: .date)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)

                        Text(item.statusText)
                            .foregroundColor(item.textColor)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 12)

                        Circle()
                            .trim(from: 0, to: item.progress)
                            .stroke(
                                item.progressColor,
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                    }
                    .frame(width: 40, height: 40)
                }

                if index < items.count - 1 {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }.containerBackground(.fill.tertiary, for: .widget)
    }
}

struct SinglePassWidgetView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            if let firstItem = entry.items.first {
                SmallWidgetView(item: firstItem)
            } else {
                Text("No passes found")
                    .font(.caption)
            }
        case .systemMedium:
            MediumWidgetView(items: entry.items)
        default:
            if let firstItem = entry.items.first {
                SmallWidgetView(item: firstItem)
            } else {
                Text("No passes found")
                    .font(.caption)
            }
        }
    }
}

struct PassMeterWidget: Widget {
    let kind: String = "PassMeterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SinglePassWidgetView(entry: entry)
        }
        .configurationDisplayName("Single Pass")
        .description("Your pass with the least time remaining.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
    }
}
