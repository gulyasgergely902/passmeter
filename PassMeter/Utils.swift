//
//  Utils.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 19..
//

import SwiftUI
import SwiftData

class Utils {
    static func calculateMaxDays(from start: Date, to end: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        let days = components.day ?? 1
        return max(1, days)
    }
}
