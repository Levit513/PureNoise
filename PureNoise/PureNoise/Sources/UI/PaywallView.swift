import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchases: PurchasesManager
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            GradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer(minLength: 0)

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Unlock all sounds")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)

                        Text("Get all 30 high-quality looping sounds. One-time purchase, no subscription.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        Button {
                            Task {
                                await buy()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                if isPurchasing {
                                    ProgressView().tint(.black)
                                } else {
                                    Text("Unlock for \(purchases.displayPrice)")
                                        .font(.headline)
                                }
                                Spacer()
                            }
                            .foregroundStyle(.black)
                            .padding(.vertical, 12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(isPurchasing)

                        Button {
                            Task { await purchases.restore() }
                        } label: {
                            Text("Restore Purchases")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.8))

                        Button {
                            dismiss()
                        } label: {
                            Text("Not now")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.35))

                        if !purchases.isConfigured {
                            Text("RevenueCat key not set yet — purchases are disabled in this build.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 0)
            }
        }
        .onAppear {
            purchases.configureIfPossible()
        }
    }

    private func buy() async {
        errorMessage = nil
        isPurchasing = true
        defer { isPurchasing = false }

        let ok = await purchases.purchaseUnlock()
        if ok {
            dismiss()
        } else {
            errorMessage = "Purchase didn’t complete. Please try again."
        }
    }
}
