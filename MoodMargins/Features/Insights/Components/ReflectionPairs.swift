//
//  ReflectionPairs.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct ReflectionPairs: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var pattern: String
    let selectedRange: Int
    let generatedRecap: PartialGeneratedInsightRecap?
    let isGeneratingRecap: Bool
    let recapErrorMessage: String?
    var retry: () -> Void = {}

    var body: some View {
        ViewThatFits(in: .horizontal) {
            if !dynamicTypeSize.isAccessibilitySize {
                HStack(alignment: .top, spacing: 22) {
                    GentlePatternCard(pattern: pattern)
                        .frame(minWidth: 320, maxWidth: .infinity, alignment: .topLeading)
                    GeneratedInsightRecapCard(
                        selectedRange: selectedRange,
                        recap: generatedRecap,
                        isGenerating: isGeneratingRecap,
                        errorMessage: recapErrorMessage,
                        retry: retry
                    )
                    .frame(minWidth: 320, maxWidth: .infinity, alignment: .topLeading)
                }
            }
            VStack(alignment: .leading, spacing: 22) {
                GentlePatternCard(pattern: pattern)
                GeneratedInsightRecapCard(
                    selectedRange: selectedRange,
                    recap: generatedRecap,
                    isGenerating: isGeneratingRecap,
                    errorMessage: recapErrorMessage,
                        retry: retry
                )
            }
        }
    }
}
