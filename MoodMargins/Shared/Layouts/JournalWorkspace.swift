import SwiftUI

/// Keeps the editor in one view subtree while the available display and fold change.
/// Navigation belongs outside this container; each pane owns its scrolling.
struct JournalWorkspace<Primary: View, Secondary: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var primary: Primary
    private var secondary: Secondary

    init(@ViewBuilder primary: () -> Primary, @ViewBuilder secondary: () -> Secondary) {
        self.primary = primary()
        self.secondary = secondary()
    }

    var body: some View {
#if os(iOS)
        if #available(iOS 27.1, *) {
            GeometryReader { geometry in
                let hasHorizontalFold = geometry.reservedRegions(kind: .division).contains {
                    $0.frame.width > $0.frame.height
                }
                ArrangementView {
                    pane { primary }
                } secondary: {
                    pane { secondary }
                }
                .arrangementViewStyle(.split.axes(hasHorizontalFold || dynamicTypeSize.isAccessibilitySize ? .vertical : .horizontal))
            }
            .toolbarVerticalCompressionBehavior(.prefersTabBar)
        } else {
            legacyWorkspace
        }
#else
        legacyWorkspace
#endif
    }

    private var legacyWorkspace: some View {
        GeometryReader { geometry in
            let usesColumns = geometry.size.width >= 800 && !dynamicTypeSize.isAccessibilitySize
            ScrollView {
                AdaptiveContentWidth(maximumWidth: usesColumns ? 1040 : 680) {
                    // AnyLayout retains the editor's identity when an iOS 27.0 window resizes.
                    let layout = usesColumns
                        ? AnyLayout(HStackLayout(alignment: .top, spacing: 24))
                        : AnyLayout(VStackLayout(alignment: .leading, spacing: 24))
                    layout {
                        primary.frame(maxWidth: .infinity, alignment: .topLeading)
                        secondary.frame(maxWidth: usesColumns ? 320 : .infinity, alignment: .topLeading)
                    }
                    .padding(usesColumns ? 24 : 16)
                }
            }
#if os(iOS) || os(macOS)
            .scrollDismissesKeyboard(.interactively)
#endif
        }
    }

    private func pane<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        ScrollView {
            AdaptiveContentWidth(maximumWidth: 680) {
                content()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
            }
        }
#if os(iOS) || os(macOS)
        .scrollDismissesKeyboard(.interactively)
#endif
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
