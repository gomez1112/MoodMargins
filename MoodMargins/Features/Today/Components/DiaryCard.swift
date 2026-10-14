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
            .diarySurface()
#if !os(visionOS)
            .overlay(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.pink.opacity(0.28))
                    .frame(width: 62, height: 18)
                    .rotationEffect(.degrees(rotation.degrees + 5))
                    .offset(x: -22, y: -9)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
#endif
    }
}
