//
//  ProgressArch.swift
//  PassMeter
//
//  Created by Gulyas Gergely on 2026. 02. 16..
//

import SwiftUI

struct ProgressArch: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat = 8
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(
                    Color.gray.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(180))
            
            Circle()
                .trim(from: 0, to: progress * 0.5)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                ) // Use the color here
                .rotationEffect(.degrees(180))
                .animation(.spring(), value: progress)
                .animation(.linear, value: color)
        }
        .frame(width: 60, height: 30)
        .padding(.vertical, 5)
    }
}
