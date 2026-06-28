//
//  InsightHeader.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct InsightHeader: View {
    @Binding var selectedRange: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Insights")
                    .font(.system(.title, design: .rounded).weight(.heavy))
                    .foregroundStyle(PastelTheme.ink)
                Text("A soft look back through your pages")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Picker("Range", selection: $selectedRange) {
                Text("7 days").tag(7)
                Text("14 days").tag(14)
                Text("30 days").tag(30)
                Text("Year").tag(365)
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    @Previewable @State var selectedRange: Int = 14
    InsightHeader(selectedRange: $selectedRange)
}
