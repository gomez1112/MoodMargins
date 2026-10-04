import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            AdaptiveContentWidth(maximumWidth: 680) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Effective date: \(PrivacyPolicyContent.effectiveDate)")
                        .font(.subheadline).foregroundStyle(.secondary)
                    ForEach(PrivacyPolicyContent.sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title).font(.headline).accessibilityAddTraits(.isHeader)
                            Text(section.body).textSelection(.enabled)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
        }
        .navigationTitle("Privacy policy")
    }
}
