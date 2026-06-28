//
//  MoodMarginsWidgetLiveActivity.swift
//  MoodMarginsWidget
//
//  Created by Gerard Gomez on 6/21/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MoodMarginsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MoodMarginsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoodMarginsWidgetAttributes.self) { context in
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

extension MoodMarginsWidgetAttributes {
    fileprivate static var preview: MoodMarginsWidgetAttributes {
        MoodMarginsWidgetAttributes(name: "World")
    }
}

extension MoodMarginsWidgetAttributes.ContentState {
    fileprivate static var smiley: MoodMarginsWidgetAttributes.ContentState {
        MoodMarginsWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MoodMarginsWidgetAttributes.ContentState {
         MoodMarginsWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MoodMarginsWidgetAttributes.preview) {
   MoodMarginsWidgetLiveActivity()
} contentStates: {
    MoodMarginsWidgetAttributes.ContentState.smiley
    MoodMarginsWidgetAttributes.ContentState.starEyes
}
