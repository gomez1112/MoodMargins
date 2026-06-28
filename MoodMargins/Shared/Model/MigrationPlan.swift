//
//  MigrationPlan.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/26/26.
//

import Foundation
import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [MoodMarginsAppSchemaV1.self]
    }
    static var stages: [MigrationStage] {
        []
    }
}
