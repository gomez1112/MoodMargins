import SwiftUI

/// Flushes a pending edit when a hinged device closes, before its display changes.
/// Geometry and native containers, rather than hinge angles, determine the layout.
struct JournalFoldAutosaveModifier: ViewModifier {
    var save: () -> Void

    func body(content: Content) -> some View {
#if os(iOS)
        if #available(iOS 27.1, *) {
            content.onHingeChange { oldContext, newContext in
                if oldContext.hinge?.status != .closed, newContext.hinge?.status == .closed {
                    save()
                }
            }
        } else {
            content
        }
#else
        content
#endif
    }
}
