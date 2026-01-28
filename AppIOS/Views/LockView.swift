import SwiftUI

struct LockView: View {
    @State private var pin: String = ""
    @State private var showError: Bool = false
    @State private var animateContent = false
    @ObservedObject var authManager = AuthManager.shared

    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Circle()
                .fill(Color.spendyPrimary.opacity(0.06))
                .frame(width: 400)
                .blur(radius: 80)
                .offset(x: -100, y: -300)

            Circle()
                .fill(Color.spendyAccent.opacity(0.05))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: 150, y: 400)

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.spendyPrimary.opacity(0.15),
                                        Color.spendyAccent.opacity(0.1),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundStyle(Color.spendyGradient)
                    }
                    .scaleEffect(animateContent ? 1 : 0.8)
                    .opacity(animateContent ? 1 : 0)

                    Text("Inserisci codice")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.spendyText)
                        .opacity(animateContent ? 1 : 0)
                }

                Group {
                    HStack(spacing: 20) {
                        ForEach(0..<6) { index in
                            PinDot(isFilled: index < pin.count, showError: showError)
                        }
                    }
                    .shake($showError)
                    .padding(.bottom, 20)

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(1...9, id: \.self) { number in
                            NativeKeypadButton(text: "\(number)") {
                                addDigit("\(number)")
                            }
                        }

                        Group {
                            if authManager.isBiometricAuthenticationInProgress {
                                Color.clear.frame(width: 75, height: 75)
                            } else {
                                Button(action: {
                                    authManager.unlockWithBiometrics()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.spendyPrimary.opacity(0.1))
                                            .frame(width: 75, height: 75)

                                        Image(systemName: "faceid")
                                            .font(.system(size: 28, weight: .medium))
                                            .foregroundStyle(Color.spendyGradient)
                                    }
                                }
                            }
                        }

                        NativeKeypadButton(text: "0") {
                            addDigit("0")
                        }

                        Button(action: {
                            deleteDigit()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 75, height: 75)

                                Image(systemName: "delete.left")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.spendySecondaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .opacity(authManager.isBiometricAuthenticationInProgress ? 0 : 1)
                .animation(
                    .easeInOut(duration: 0.3),
                    value: authManager.isBiometricAuthenticationInProgress)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                authManager.unlockWithBiometrics()
            }
        }
    }

    private func addDigit(_ digit: String) {
        if pin.count < 6 {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                pin.append(digit)
            }
            if pin.count == 6 {
                verifyPin()
            }
        }
    }

    private func deleteDigit() {
        if !pin.isEmpty {
            let _ = withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                pin.removeLast()
            }
            showError = false
        }
    }

    private func verifyPin() {
        if authManager.unlock(with: pin) {
            pin = ""
        } else {
            showError = true
            pin = ""
        }
    }
}

struct PinDot: View {
    let isFilled: Bool
    let showError: Bool

    var body: some View {
        Circle()
            .fill(isFilled ? (showError ? Color.spendyRed : Color.spendyPrimary) : Color.clear)
            .frame(width: 16, height: 16)
            .overlay(
                Circle()
                    .stroke(
                        showError ? Color.spendyRed : Color.spendyPrimary.opacity(0.3), lineWidth: 2
                    )
            )
            .scaleEffect(isFilled ? 1.1 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isFilled)
    }
}
