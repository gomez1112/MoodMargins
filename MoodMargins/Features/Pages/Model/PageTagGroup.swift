//
//  PageTagGroup.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

struct PageTagGroup: Identifiable {
    let title: String
    let tags: [String]

    var id: String { title }
}
