//
//  ListItem.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 19..
//

import SwiftUI
import SwiftData

struct ListItem: View {
    let item: Item
    var onCheckIn: (Item) -> Void

    var body: some View {
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
					.font(.system(.headline, design: .rounded))

				HStack(spacing: 2) {
					Text(item.statusText)
						.foregroundColor(item.statusDisplay.textColor)
						.font(.system(.subheadline, design: .rounded))
						.foregroundStyle(.secondary)
					if item.hasEntryLimit {
						Text("•")
							.foregroundColor(item.statusDisplay.textColor)
							.font(.system(.subheadline, design: .rounded))
							.foregroundStyle(.secondary)
						Text(item.entryCountText)
							.foregroundColor(item.statusDisplay.textColor)
							.font(.system(.subheadline, design: .rounded))
							.foregroundStyle(.secondary)
					}
				}
				
				HStack(spacing: 2) {
					Text(item.expiryDate.formatted(date: .abbreviated, time: .omitted))
						.font(.system(.caption, design: .rounded))
						.foregroundStyle(.secondary)
					if item.isNotificationEnabled {
						Image(systemName: "bell.fill")
							.font(.system(.caption, design: .rounded))
							.foregroundStyle(.secondary)
					}
				}
            }
        }
        .padding(.vertical, 4)
    }
}
