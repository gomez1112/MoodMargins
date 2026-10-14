#if os(visionOS)
import SwiftUI

struct VisionWelcomeView: View {
    @Environment(\.diaryPalette) private var palette
    @State private var previewMood = Mood.wink
    var onComplete: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("A softer place to check in")
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .accessibilityAddTraits(.isHeader)
                        Text("Pick a mood, jot a few lines, and save the small moments that usually slip past.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .center, spacing: 32) {
                            notebookPreview.frame(minWidth: 310, maxWidth: 350)
                            features.frame(minWidth: 280, maxWidth: .infinity)
                        }
                        VStack(alignment: .leading, spacing: 28) {
                            notebookPreview
                            features
                        }
                    }
                    Text(.visionWelcomePrivacy)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 760, alignment: .leading)
                .padding(32)
                .frame(maxWidth: .infinity)
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button("Start journaling", action: onComplete)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .accessibilityIdentifier("start-journaling")
                }
                .padding(24)
                .background(.regularMaterial)
            }
            .navigationTitle("MoodMargins")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip", systemImage: "xmark", action: onComplete)
                        .labelStyle(.iconOnly)
                }
            }
        }
        .tint(palette.action)
        .frame(idealWidth: 800, idealHeight: 660)
    }

    private var notebookPreview: some View {
        VStack(alignment: .leading, spacing: 20) {
            MoodPicker(selection: $previewMood, title: String(localized: .visionWelcomeHint))
            Divider()
            Text("Dear diary…")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(.secondary)
            Text(.visionWelcomeSample)
                .font(.system(.title2, design: .serif))
                .fixedSize(horizontal: false, vertical: true)
            Rectangle().fill(.primary.opacity(0.12)).frame(height: 1)
            Rectangle().fill(.primary.opacity(0.12)).frame(height: 1)
        }
        .padding(24)
        .diarySurface(cornerRadius: 24)
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 24) {
            feature(title: "Daily mood pages", detail: .visionWelcomeAutoSave, symbol: "book.pages.fill")
            feature(title: "Past page browsing", detail: "Revisit entries by date, mood, and search so older reflections stay easy to find.", symbol: "calendar")
            feature(title: "Gentle insights", detail: .visionWelcomeInsights, symbol: "sparkles")
        }
    }

    private func feature(title: LocalizedStringKey, detail: LocalizedStringResource, symbol: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(palette.action)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}
#endif
