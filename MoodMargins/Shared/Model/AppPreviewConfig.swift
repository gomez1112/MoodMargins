//
//  AppPreviewConfig.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/26/26.
//

import Foundation
import SwiftData
import SwiftUI
import EZSwiftData

enum AppPreviewConfig: SwiftDataPreviewContextConfig {
    static let models: [any PersistentModel.Type] = [
        MoodEntry.self, Activity.self
    ]
    
    @MainActor
    static func seed(_ context: ModelContext) throws {
        for mood in MoodEntry.samples {
            context.insert(mood)
        }
    }
}

struct PreviewDependencies: ViewModifier {
    let context: ModelContext
    
    func body(content: Content) -> some View {
        content
            .environment(NavigationContext())
    }
}
