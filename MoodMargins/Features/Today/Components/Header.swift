import SwiftUI

struct Header: View {
    var streak: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top) {
                title
                Spacer()
                streakBadge.fixedSize(horizontal: true, vertical: false)
            }
            VStack(alignment: .leading, spacing: 12) {
                title
                streakBadge
            }
        }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today")
                .font(.system(.title, design: .rounded).bold())
                .foregroundStyle(PastelTheme.ink)
                .accessibilityAddTraits(.isHeader)
            Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var streakBadge: some View {
        Text("\(streak)-day streak")
            .font(.system(.caption, design: .rounded).bold())
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(PastelTheme.paper, in: Capsule())
            .foregroundStyle(PastelTheme.ink)
    }
}
