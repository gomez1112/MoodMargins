//
//  ReflectionPairs.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct ReflectionPairs: View {
    let selectedRange: Int
    let generatedRecap: PartialGeneratedInsightRecap?
    let isGeneratingRecap: Bool
    let recapErrorMessage: String?

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 22) {
                GentlePatternCard()
                    .frame(minWidth: 320, maxWidth: .infinity, alignment: .topLeading)
                GeneratedInsightRecapCard(
                    selectedRange: selectedRange,
                    recap: generatedRecap,
                    isGenerating: isGeneratingRecap,
                    errorMessage: recapErrorMessage
                )
                .frame(minWidth: 320, maxWidth: .infinity, alignment: .topLeading)
            }

            VStack(alignment: .leading, spacing: 22) {
                GentlePatternCard()
                GeneratedInsightRecapCard(
                    selectedRange: selectedRange,
                    recap: generatedRecap,
                    isGenerating: isGeneratingRecap,
                    errorMessage: recapErrorMessage
                )
            }
        }
    }
}

#Preview {
    ReflectionPairs(
        selectedRange: 14,
        generatedRecap: .fallback(for: 14),
        isGeneratingRecap: false,
        recapErrorMessage: nil
    )
}
