//
//  GeneratedInsightRecapCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/28/26.
//

import SwiftUI

struct GeneratedInsightRecapCard: View {
    let selectedRange: Int
    let recap: PartialGeneratedInsightRecap?
    let isGenerating: Bool
    let errorMessage: String?

    private var title: String {
        text(recap?.title) ?? (selectedRange == 365 ? String(localized: "Year recap") : String(localized: "\(selectedRange)-day recap"))
    }

    var body: some View {
        InsightPage(title: title, symbol: "text.book.closed.fill", rotation: -0.8) {
            VStack(alignment: .leading, spacing: 12) {
                if let pattern = text(recap?.pattern) {
                    Text(pattern)
                        .font(.system(.body, design: .serif))
                        .lineSpacing(5)
                        .foregroundStyle(.primary.opacity(0.84))
                } else if isGenerating {
                    loadingLine(String(localized: "Looking for a gentle pattern"))
                } else if let errorMessage {
                    statusLine(errorMessage, systemImage: "sparkles")
                } else {
                    statusLine(String(localized: "Add a little more detail to unlock a generated recap."), systemImage: "text.book.closed")
                }

                if let supportingDetail = text(recap?.supportingDetail) {
                    Label(supportingDetail, systemImage: "sparkle.magnifyingglass")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                if let gentleReflection = text(recap?.gentleReflection) {
                    Text(gentleReflection)
                        .font(.system(.callout, design: .serif))
                        .foregroundStyle(PastelTheme.ink.opacity(0.74))
                }

                if let nextPrompt = text(recap?.nextPrompt) {
                    Text(nextPrompt)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.62)))
                        .foregroundStyle(PastelTheme.ink)
                }

                if isGenerating {
                    loadingLine(String(localized: "Writing recap"))
                } else if let errorMessage, text(recap?.pattern) != nil {
                    statusLine(errorMessage, systemImage: "sparkles")
                }
            }
            .animation(.easeInOut(duration: 0.2), value: recap)
        }
    }

    private func loadingLine(_ text: String) -> some View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)
            Text(text)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private func statusLine(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.system(.caption, design: .rounded).weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func text(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}

#Preview {
    GeneratedInsightRecapCard(
        selectedRange: 14,
        recap: PartialGeneratedInsightRecap(
            title: "A steadier week",
            pattern: "Your calmer tags showed up near the days with higher moods.",
            supportingDetail: "Top tags included calm and rest.",
            gentleReflection: "The small routines seem worth noticing.",
            nextPrompt: "What helped today feel a little softer?"
        ),
        isGenerating: false,
        errorMessage: nil
    )
}
