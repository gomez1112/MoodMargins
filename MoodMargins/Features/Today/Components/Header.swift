//
//  Header.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/26/26.
//

import SwiftUI

struct Header: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("Today")
                    .font(.system(.title, design: .rounded).weight(.heavy))
                    .foregroundStyle(PastelTheme.ink)
                Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("3-day streak")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .padding()
                .background(Capsule().fill(.white.opacity(0.55)))
                .foregroundStyle(PastelTheme.ink)
        }
    }
}

#Preview {
    Header()
}
