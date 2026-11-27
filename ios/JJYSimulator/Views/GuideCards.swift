import SwiftUI

/// Warning callout and 4-step usage instructions matching the web version.
struct HowToUseCard: View {
    @Environment(\.colorScheme) private var colorScheme

    private let stepKeys: [LocalizedStringKey] = [
        "guide.step1",
        "guide.step2",
        "guide.step3",
        "guide.step4",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("guide.warning")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.stopRed)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                Text("guide.title")
                    .font(.headline)
                    .foregroundStyle(Theme.fg(for: colorScheme))
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(stepKeys.enumerated()), id: \.offset) { idx, key in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(idx + 1).")
                                .font(.subheadline.weight(.medium))
                                .monospacedDigit()
                                .foregroundStyle(Theme.muted(for: colorScheme))

                            Text(key)
                                .font(.subheadline)
                                .foregroundStyle(Theme.fg(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .simulatorCard()
    }
}

/// Explanation card ("How does it work?", "Using abroad", "Which watches work?").
struct FAQCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            faqSection(title: "faq.how.title", body: "faq.how.body")
            faqSection(title: "faq.abroad.title", body: "faq.abroad.body")
            faqSection(title: "faq.watches.title", body: "faq.watches.body")
        }
        .simulatorCard()
    }

    @ViewBuilder
    private func faqSection(title: LocalizedStringKey, body: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.fg(for: colorScheme))

            Text(body)
                .font(.subheadline)
                .foregroundStyle(Theme.fg(for: colorScheme).opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
