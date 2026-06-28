//
//  InsightSticker.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import SwiftUI

struct InsightSticker: View {
    let title: String
    let value: String
    let systemName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.pink.opacity(0.65))
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(PastelTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(PastelTheme.paper, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 5, y: 3)
    }
}

#Preview {
    InsightSticker(title: "Title", value: "Value", systemName: "house")
}
