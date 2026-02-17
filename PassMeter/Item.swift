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
    
    init(title: String, startDate: Date, expiryDate: Date) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.expiryDate = expiryDate
    }
    
    var progressRatio: Double {
        let now = Date()
        let passDuration = expiryDate.timeIntervalSince(startDate)
        let elapsedSinceStart = now.timeIntervalSince(startDate)

        if elapsedSinceStart < 0 {
            return 1.0
        }

        let ratio = 1.0 - (elapsedSinceStart / passDuration)

        return max(0, min(1.0, ratio))
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: today, to: end).day ?? 0
    }

    var isExpired: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let expiry = calendar.startOfDay(for: expiryDate)

        return expiry < today
    }

    var statusDisplay: (statusText: String, progressColor: Color, textColor: Color) {
        if isExpired {
            return (statusText: "Expired", progressColor: .gray, textColor: .red)
        }

        let calendar = Calendar.current
        if calendar.isDateInToday(expiryDate) {
            return (statusText: "Today", progressColor: .red, textColor: .red)
        }

        let days = daysRemaining
        let _textColor: Color = days <= 3 ? .red : (days <= 7 ? .yellow : .gray)
        let _progressColor: Color = days <= 3 ? .red : (days <= 7 ? .yellow : .blue)
        let _statusText = "Expires \(expiryDate.formatted(.relative(presentation: .numeric)))."

        return (statusText: _statusText, progressColor: _progressColor, textColor: _textColor)
    }
}
