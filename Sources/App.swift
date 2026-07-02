import SwiftUI
import AppFactoryKit

// Transcriber — payments via native StoreKit 2 (no third-party SDK).
private enum Product {
    static let yearly = "transcriber_pro_yearly"
    static let weekly = "transcriber_pro_weekly"
}

@MainActor
enum TranscriberFactory {
    static func make() -> AppFactory {
        let config = AppFactoryConfiguration(
            appName: "Transcriber",
            purchaseProvider: StoreKit2PurchaseProvider(productIDs: [Product.yearly, Product.weekly]),
            onboarding: OnboardingConfiguration(
                slides: [
                    .init(systemImage: "mic.circle.fill",
                          title: "Record Anything",
                          message: "Meetings, lectures, ideas — capture them with one tap."),
                    .init(systemImage: "text.quote",
                          title: "Words, Instantly",
                          message: "Your recording becomes editable text on-device. Copy it, share it, keep it.")
                ],
                presentsPaywallOnFinish: true,
                accent: .pink
            ),
            paywall: PaywallConfiguration(
                headline: "Unlock Transcriber Pro",
                subheadline: "Every word, captured and exported.",
                benefits: [
                    .init(systemImage: "infinity", title: "Unlimited recording length"),
                    .init(systemImage: "square.and.arrow.up", title: "Export transcripts"),
                    .init(systemImage: "lock.shield", title: "100% on-device privacy"),
                    .init(systemImage: "nosign", title: "No ads")
                ],
                productIDs: [Product.yearly, Product.weekly],
                highlightedProductID: Product.yearly,
                ctaTitle: "Continue",
                dismissButtonDelay: 4,
                isDismissable: true,
                termsURL: URL(string: "https://zubeidhendricks.github.io/VoiceMemoTranscriber/terms.html"),
                privacyURL: URL(string: "https://zubeidhendricks.github.io/VoiceMemoTranscriber/privacy.html"),
                style: PaywallStyle(accent: .pink, heroSystemImage: "waveform.circle")
            )
        )
        return AppFactory(config)
    }
}

@main
struct TranscriberApp: App {
    @StateObject private var factory = TranscriberFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appFactoryRoot(factory)
                .tint(.pink)
        }
    }
}
