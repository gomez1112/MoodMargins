//
//  DiaryCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/21/26.
//

import SwiftUI

struct DiaryCard<Content: View>: View {
    let rotation: Angle
    @ContentBuilder var content: () -> Content
    
    var body: some View {
        content()
            .padding()
            .background(PastelTheme.paper, in: RoundedRectangle(cornerRadius: 18))
            .overlay(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.pink.opacity(0.28))
                    .frame(width: 62, height: 18)
                    .rotationEffect(.degrees(5))
                    .offset(x: -22, y: -9)
            }
            .rotationEffect(rotation)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

#Preview {
    DiaryCard(rotation: .degrees(-2)) {
        Text("Today felt soft around the edges.")
            .font(.system(.body, design: .serif))
    }
}
