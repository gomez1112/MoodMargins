#if os(visionOS)
import OnboardingKit
import SwiftUI

/// Uses the shared onboarding pages with native spatial materials and controls.
struct VisionWelcomeView: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize = 80.0
    @State private var currentPage = 0
    @AccessibilityFocusState private var isPageFocused: Bool
    var pages: [OnboardingPage]
    var copy: OnboardingCopy
    var onComplete: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                if let page {
                    VStack(spacing: 24) {
                        pageIcon(page.icon)
                            .font(.system(size: min(symbolSize, 136)))
                            .foregroundStyle(palette.action)
                            .frame(minHeight: 120)
                            .accessibilityHidden(true)
                        Text(page.title)
                            .font(.largeTitle.bold())
                            .accessibilityAddTraits(.isHeader)
                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 520)
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                    .accessibilityFocused($isPageFocused)
                    .id(currentPage)
                    .transition(.opacity)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? palette.action : Color.secondary.opacity(0.4))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .accessibilityHidden(true)
                    Button(isLastPage ? copy.getStartedButtonTitle : copy.nextButtonTitle, action: advance)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .accessibilityIdentifier(isLastPage ? "start-journaling" : "onboarding-next")
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(.regularMaterial)
            }
            .navigationTitle("MoodMargins")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(copy.skipButtonTitle, systemImage: "xmark", action: onComplete)
                        .labelStyle(.iconOnly)
                        .accessibilityIdentifier("skip-onboarding")
                }
            }
        }
        .tint(palette.action)
        .frame(idealWidth: 600, idealHeight: 600)
        .animation(reduceMotion ? nil : .snappy, value: currentPage)
        .onChange(of: currentPage) { isPageFocused = true }
    }

    private var page: OnboardingPage? {
        pages.indices.contains(currentPage) ? pages[currentPage] : nil
    }

    private var isLastPage: Bool { currentPage >= pages.count - 1 }

    @ViewBuilder
    private func pageIcon(_ icon: OnboardingIcon) -> some View {
        switch icon {
        case .system(let name): Image(systemName: name)
        case .asset(let name): Image(name).resizable().scaledToFit().frame(maxHeight: 120)
        }
    }

    private func advance() {
        if isLastPage {
            onComplete()
        } else {
            currentPage += 1
        }
    }
}
#endif
