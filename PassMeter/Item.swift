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
    var title: String
    var expiryDate: Date
    var totalDays: Int
    
    init(title: String, expiryDate: Date, totalDays: Int) {
        self.title = title
        self.expiryDate = expiryDate
        self.totalDays = totalDays
    }
    
    var progressRatio: Double {
        guard totalDays > 0 else { return 0 }
        let remaining = Double(daysRemaining)
        return max(0, min(1.0, remaining / Double(totalDays)))
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var statusColor: Color {
        let days = daysRemaining
        if days <= 3 {
            return .red
        } else if days <= 7 {
            return .yellow
        } else {
            return .blue
        }
    }
}
