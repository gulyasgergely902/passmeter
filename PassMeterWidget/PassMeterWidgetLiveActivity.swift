//
//  PassMeterWidgetLiveActivity.swift
//  PassMeterWidget
//
//  Created by Gulyas Gergely on 2026. 02. 17..
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PassMeterWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PassMeterWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PassMeterWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PassMeterWidgetAttributes {
    fileprivate static var preview: PassMeterWidgetAttributes {
        PassMeterWidgetAttributes(name: "World")
    }
}

extension PassMeterWidgetAttributes.ContentState {
    fileprivate static var smiley: PassMeterWidgetAttributes.ContentState {
        PassMeterWidgetAttributes.ContentState(emoji: "😀")
     }

     fileprivate static var starEyes: PassMeterWidgetAttributes.ContentState {
         PassMeterWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PassMeterWidgetAttributes.preview) {
   PassMeterWidgetLiveActivity()
} contentStates: {
    PassMeterWidgetAttributes.ContentState.smiley
    PassMeterWidgetAttributes.ContentState.starEyes
}
