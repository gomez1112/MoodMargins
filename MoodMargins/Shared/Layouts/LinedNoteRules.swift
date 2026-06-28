//
//  LinedNoteRules.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct LinedNoteRules: View {
    let lines: Int
    let rowHeight: CGFloat
    let firstRuleOffset: CGFloat
    let lineColor: Color

    var body: some View {
        VStack(spacing: rowHeight - 1) {
            ForEach(0..<lines, id: \.self) { _ in
                Rectangle()
                    .fill(lineColor.opacity(0.45))
                    .frame(height: 1)
            }
        }
        .padding(.top, firstRuleOffset)
        .allowsHitTesting(false)
    }
}

#Preview {
    LinedNoteRules(
        lines: 5,
        rowHeight: 31,
        firstRuleOffset: 27,
        lineColor: PastelTheme.lavenderLine
    )
    .padding()
    .background(PastelTheme.background)
}
