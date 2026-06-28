//
//  ActivityCount.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import Foundation

struct ActivityCount: Identifiable {
    var id: String {
        activity.id.uuidString
    }
    let activity: Activity
    let count: Int
}
