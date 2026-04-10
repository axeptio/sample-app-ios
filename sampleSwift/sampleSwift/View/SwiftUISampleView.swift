//
//  SwiftUISampleView.swift
//  sampleSwift
//
//  Demonstrates SwiftUI-native Axeptio SDK integration using
//  .axeptioConsent() and AxeptioStore.
//

import SwiftUI
import AxeptioSDK

struct SwiftUISampleView: View {
    @StateObject private var axeptio = AxeptioStore()

    var body: some View {
        VStack(spacing: 24) {
            Text("SwiftUI Integration")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Label(
                    "Consent saved: \(axeptio.consentSaved ? "Yes" : "No")",
                    systemImage: axeptio.consentSaved ? "checkmark.circle.fill" : "circle"
                )
                .foregroundColor(axeptio.consentSaved ? .green : .secondary)

                if let google = axeptio.googleConsentV2 {
                    Label(
                        "Analytics: \(google.analyticsStorage.rawValue)",
                        systemImage: "chart.bar"
                    )
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            Button("Show Consent Screen") {
                Axeptio.shared.showConsentScreen()
            }
            .buttonStyle(.borderedProminent)

            Button("Clear Consent") {
                Axeptio.shared.clearConsent()
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
        .navigationTitle("SwiftUI Demo")
        // Triggers setupUI() — no AppDelegate needed
        .axeptioConsent()
    }
}
