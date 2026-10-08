import CryptoKit
import Foundation
import LocalAuthentication

@MainActor
final class LockStore: ObservableObject {
    @Published var isUnlocked: Bool
    @Published var isLockEnabled: Bool {
        didSet { UserDefaults.standard.set(isLockEnabled, forKey: Keys.enabled) }
    }
    @Published var biometricsEnabled: Bool {
        didSet { UserDefaults.standard.set(biometricsEnabled, forKey: Keys.biometrics) }
    }

    private var pinHash: String? {
        get { UserDefaults.standard.string(forKey: Keys.pinHash) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.pinHash) }
    }

    var hasPIN: Bool { pinHash != nil }

    private enum Keys {
        static let enabled = "soft_diary_lock_enabled"
        static let biometrics = "soft_diary_lock_biometrics"
        static let pinHash = "soft_diary_pin_hash"
    }

    init() {
        isLockEnabled = UserDefaults.standard.bool(forKey: Keys.enabled)
        biometricsEnabled = UserDefaults.standard.bool(forKey: Keys.biometrics)
        // When lock is enabled, start locked on cold launch
        isUnlocked = !UserDefaults.standard.bool(forKey: Keys.enabled)
    }

    func setPIN(_ pin: String) {
        pinHash = Self.hash(pin)
        isLockEnabled = true
        isUnlocked = true
    }

    func clearPIN() {
        pinHash = nil
        isLockEnabled = false
        biometricsEnabled = false
        isUnlocked = true
    }

    func verifyPIN(_ pin: String) -> Bool {
        guard let pinHash else { return false }
        let ok = Self.hash(pin) == pinHash
        if ok { isUnlocked = true }
        return ok
    }

    func lockIfNeeded() {
        if isLockEnabled && hasPIN {
            isUnlocked = false
        }
    }

    func unlockWithBiometrics() async -> Bool {
        guard biometricsEnabled else { return false }
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock SoftDiary"
            )
            if success { isUnlocked = true }
            return success
        } catch {
            return false
        }
    }

    var biometryLabel: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Biometrics"
        }
    }

    var canUseBiometrics: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    private static func hash(_ pin: String) -> String {
        let digest = SHA256.hash(data: Data(pin.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
