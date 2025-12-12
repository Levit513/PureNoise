import Foundation
import SwiftUI

#if canImport(RevenueCat)
import RevenueCat
#endif

@MainActor
final class PurchasesManager: ObservableObject {
    static let shared = PurchasesManager()

    // One-time unlock (remove banner + unlock all sounds)
    static let unlockEntitlementID = "unlock_all_sounds"
    static let unlockProductID = "com.levit513.purenoise.unlock"

    @AppStorage("purenoise_is_unlocked") private var persistedUnlocked: Bool = false

    @Published private(set) var isConfigured: Bool = false
    @Published private(set) var isUnlocked: Bool = false

    // Display price (actual App Store price is fetched by RevenueCat once configured)
    @Published private(set) var displayPrice: String = "$6.99"

    private init() {
        isUnlocked = persistedUnlocked
    }

    func configureIfPossible() {
        guard !isConfigured else { return }
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PURENOISE_REVENUECAT_API_KEY") as? String,
              !apiKey.isEmpty,
              apiKey != "REPLACE_ME" else {
            // App runs without purchases in dev until key is provided.
            isConfigured = false
            return
        }

        #if canImport(RevenueCat)
        Purchases.logLevel = .warn
        Purchases.configure(withAPIKey: apiKey)
        isConfigured = true

        Task { await refreshCustomerInfo() }
        Task { await refreshOfferings() }
        #else
        isConfigured = false
        #endif
    }

    func refreshCustomerInfo() async {
        #if canImport(RevenueCat)
        do {
            let info = try await Purchases.shared.customerInfo()
            let active = info.entitlements.active[Self.unlockEntitlementID] != nil
            applyUnlocked(active)
        } catch {
            // Keep persisted state.
        }
        #endif
    }

    func refreshOfferings() async {
        #if canImport(RevenueCat)
        do {
            let offerings = try await Purchases.shared.offerings()
            if let package = offerings.current?.availablePackages.first(where: { $0.storeProduct.productIdentifier == Self.unlockProductID }) {
                displayPrice = package.storeProduct.localizedPriceString
            }
        } catch {
            // ignore
        }
        #endif
    }

    func purchaseUnlock() async -> Bool {
        #if canImport(RevenueCat)
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let package = offerings.current?.availablePackages.first(where: { $0.storeProduct.productIdentifier == Self.unlockProductID }) else {
                return false
            }
            let result = try await Purchases.shared.purchase(package: package)
            let active = result.customerInfo.entitlements.active[Self.unlockEntitlementID] != nil
            applyUnlocked(active)
            return active
        } catch {
            return false
        }
        #else
        return false
        #endif
    }

    func restore() async {
        #if canImport(RevenueCat)
        do {
            let info = try await Purchases.shared.restorePurchases()
            let active = info.entitlements.active[Self.unlockEntitlementID] != nil
            applyUnlocked(active)
        } catch {
            // ignore
        }
        #endif
    }

    private func applyUnlocked(_ value: Bool) {
        isUnlocked = value
        persistedUnlocked = value
    }
}
