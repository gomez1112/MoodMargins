//
//  MoodMarginsWidgetBundle.swift
//  MoodMarginsWidget
//
//  Created by Gerard Gomez on 6/21/26.
//

import WidgetKit
import SwiftUI

@main
struct MoodMarginsWidgetBundle: WidgetBundle {
    var body: some Widget {
        MoodMarginsWidget()
        MoodMarginsWidgetControl()
        MoodMarginsWidgetLiveActivity()
    }
}
