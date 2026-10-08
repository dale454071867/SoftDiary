import SwiftUI

struct LockScreenView: View {
    @EnvironmentObject private var lockStore: LockStore

    @State private var pin = ""
    @State private var shake = false
    @State private var errorTip = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.skyTop, AppTheme.lavender.opacity(0.5), AppTheme.skyBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                CharacterPortraitView(mood: .curious, pose: .shy, height: 150)

                Text("Journal locked")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)

                Text("Enter your 4-digit passcode")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.inkSoft)

                HStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < pin.count ? AppTheme.accent : Color.white.opacity(0.55))
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(AppTheme.accent.opacity(0.35), lineWidth: 1))
                    }
                }
                .offset(x: shake ? -10 : 0)
                .animation(.default.repeatCount(3, autoreverses: true), value: shake)

                if errorTip {
                    Text("Incorrect passcode")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(Color(hex: 0xFF8A80))
                }

                if lockStore.biometricsEnabled && lockStore.canUseBiometrics {
                    Button {
                        Task {
                            _ = await lockStore.unlockWithBiometrics()
                        }
                    } label: {
                        Label("Use \(lockStore.biometryLabel)", systemImage: "faceid")
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(AppTheme.ink)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(AppTheme.butter.opacity(0.8)))
                    }
                    .buttonStyle(CartoonPressStyle())
                    .padding(.top, 4)
                }

                Spacer()

                PinPad(pin: $pin, maxDigits: 4) { value in
                    handlePinChange(value)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            if lockStore.biometricsEnabled {
                Task {
                    _ = await lockStore.unlockWithBiometrics()
                }
            }
        }
    }

    private func handlePinChange(_ value: String) {
        pin = value
        errorTip = false
        guard pin.count == 4 else { return }
        if lockStore.verifyPIN(pin) {
            pin = ""
        } else {
            errorTip = true
            shake = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                shake = false
                pin = ""
            }
        }
    }
}

struct PinPad: View {
    @Binding var pin: String
    var maxDigits: Int = 4
    var onChange: (String) -> Void

    private let keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "⌫"]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                if key.isEmpty {
                    Color.clear.frame(height: 56)
                } else {
                    Button {
                        tap(key)
                    } label: {
                        Text(key)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white.opacity(0.7))
                            )
                    }
                    .buttonStyle(CartoonPressStyle())
                }
            }
        }
    }

    private func tap(_ key: String) {
        var next = pin
        if key == "⌫" {
            if !next.isEmpty { next.removeLast() }
        } else if next.count < maxDigits {
            next.append(key)
        }
        onChange(next)
    }
}

struct PINSetupView: View {
    @EnvironmentObject private var lockStore: LockStore
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    @State private var firstPIN = ""
    @State private var pin = ""
    @State private var tip = ""

    var body: some View {
        NavigationStack {
            ZStack {
                CartoonBackground()

                VStack(spacing: 20) {
                    CharacterPortraitView(mood: .calm, pose: .idle, height: 120)
                        .padding(.top, 20)

                    Text(step == 0 ? "Set a 4-digit passcode" : "Enter again to confirm")
                        .font(AppTheme.titleFont)
                        .foregroundStyle(AppTheme.ink)

                    HStack(spacing: 14) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index < pin.count ? AppTheme.accent : Color.white.opacity(0.55))
                                .frame(width: 16, height: 16)
                        }
                    }

                    if !tip.isEmpty {
                        Text(tip)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(Color(hex: 0xFF8A80))
                    }

                    Spacer()

                    PinPad(pin: $pin) { value in
                        pin = value
                        tip = ""
                        guard pin.count == 4 else { return }
                        if step == 0 {
                            firstPIN = pin
                            pin = ""
                            step = 1
                        } else if pin == firstPIN {
                            lockStore.setPIN(pin)
                            dismiss()
                        } else {
                            tip = "Passcodes don’t match. Please try again."
                            step = 0
                            firstPIN = ""
                            pin = ""
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Passcode Lock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.inkSoft)
                }
            }
        }
    }
}
