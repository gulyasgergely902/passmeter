//
//  Item.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 16..
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
	@Attribute(.unique) var id: UUID = UUID()
	var title: String
	var startDate: Date
	var expiryDate: Date

	var hasEntryLimit: Bool = false
	var totalEntries: Int = 0
	var remainingEntries: Int = 0

	var isNotificationEnabled: Bool = false
	var reminderNotificationDate: Date

	var entries: [Date] = []

	init(title: String, startDate: Date, expiryDate: Date, hasEntryLimit: Bool = false, totalEntries: Int = 0, isNotificationsEnabled: Bool = false, reminderNotificationDate: Date) {
		self.id = UUID()
		self.title = title
		self.startDate = startDate
		self.expiryDate = expiryDate
		self.hasEntryLimit = hasEntryLimit
		self.totalEntries = totalEntries
		self.remainingEntries = totalEntries
		self.isNotificationEnabled = isNotificationsEnabled
		self.reminderNotificationDate = reminderNotificationDate
	}

	var progressRatio: (dateProgressRatio: Double, entryProgressRatio: Double) {
		let calendar = Calendar.current
		let endOfExpiryDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: expiryDate) ?? expiryDate

		let passDuration = endOfExpiryDay.timeIntervalSince(startDate)
		let elapsedSinceStart = Date().timeIntervalSince(startDate)

		var dateProgress: Double = 0
		if elapsedSinceStart < 0 {
			dateProgress = 1.0
		}

		let ratio = 1.0 - (elapsedSinceStart / passDuration)
		dateProgress = max(0, min(1.0, ratio))

		var entryProgress: Double = 0
		if hasEntryLimit && totalEntries > 0 {
			let usedEntries = totalEntries - remainingEntries
			entryProgress = Double(totalEntries - usedEntries) / Double(totalEntries)
		}

		return (dateProgressRatio: dateProgress, entryProgressRatio: entryProgress)
	}

	var daysRemaining: Int {
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: .now)
		let end = calendar.startOfDay(for: expiryDate)
		return calendar.dateComponents([.day], from: today, to: end).day ?? 0
	}

	var isNearExpiry: Bool {
		return daysRemaining <= 3 || (hasEntryLimit && remainingEntries <= 2)
	}

	var isExpired: Bool {
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: .now)
		let expiry = calendar.startOfDay(for: expiryDate)

		let basedOnTime = expiry < today

		let basedOnEntryCount = (hasEntryLimit && remainingEntries <= 0)

		return basedOnTime || basedOnEntryCount
	}

	var statusDisplay: (statusText: String, progressColor: Color, textColor: Color) {
		if isExpired {
			return (statusText: "Expired", progressColor: .gray, textColor: .red)
		}

		let calendar = Calendar.current
		if calendar.isDateInToday(expiryDate) {
			return (statusText: "Expires Today", progressColor: .red, textColor: .red)
		}

		let days = daysRemaining
		let _textColor: Color = days <= 3 ? .red : (days <= 7 ? .yellow : .gray)
		let _progressColor: Color = days <= 3 ? .red : (days <= 7 ? .yellow : .blue)
		let _statusText = "Expires \(expiryDate.formatted(.relative(presentation: .numeric)))."

		return (statusText: _statusText, progressColor: _progressColor, textColor: _textColor)
	}

	var entryCountProgressColor: Color {
		if remainingEntries <= 1 {
			return .red
		} else if remainingEntries <= 3 {
			return .yellow
		} else {
			return .green
		}
	}
}
