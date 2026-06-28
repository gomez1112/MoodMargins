//
//  PageDateHeader.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct PageDateHeader: View {
    let date: Date
    let ink: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(date, format: .dateTime.weekday(.wide))
                .font(.system(.title, design: .rounded).weight(.heavy))
                .foregroundStyle(ink)
            Text(date, format: .dateTime.month(.wide).day().year())
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PageDateHeader(date: Date(), ink: PastelTheme.ink)
}
