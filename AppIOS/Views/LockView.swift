import SwiftUI

struct LockView: View {
    @State private var pin: String = ""
    @State private var showError: Bool = false
    @ObservedObject var authManager = AuthManager.shared

    // Number pad layout
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ZStack {
            // Background - White as requested
            Color.white.ignoresSafeArea()

            VStack(spacing: 50) {
                Spacer()

                VStack(spacing: 20) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.black)

                    Text("Inserisci codice")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.black)
                }

                // PIN Dots and Keypad
                Group {
                    // PIN Dots - Liquid Style
                    HStack(spacing: 25) {
                        ForEach(0..<6) { index in
                            Circle()
                                .fill(index < pin.count ? Color.black : Color.clear)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                    .shake($showError)
                    .padding(.bottom, 30)

                    // Numpad - Liquid Glass Buttons
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(1...9, id: \.self) { number in
                            LiquidKeypadButton(number: "\(number)") {
                                addDigit("\(number)")
                            }
                        }

                        // FaceID / Empty
                        Group {
                            if authManager.isBiometricAuthenticationInProgress {
                                Color.clear.frame(width: 75, height: 75)
                            } else {
                                Button(action: {
                                    authManager.unlockWithBiometrics()
                                }) {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 28))
                                        .foregroundColor(.black)
                                        .frame(width: 75, height: 75)
                                }
                            }
                        }

                        LiquidKeypadButton(number: "0") {
                            addDigit("0")
                        }

                        // Delete
                        Button(action: {
                            deleteDigit()
                        }) {
                            Text("Elimina")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .frame(width: 75, height: 75)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
                .opacity(authManager.isBiometricAuthenticationInProgress ? 0 : 1)
                .animation(
                    .easeInOut(duration: 0.3),
                    value: authManager.isBiometricAuthenticationInProgress)

                Spacer()
            }
        }
        .onAppear {
            // Small delay to allow UI to settle before prompting FaceID
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                authManager.unlockWithBiometrics()
            }
        }
    }

    private func addDigit(_ digit: String) {
        if pin.count < 6 {
            pin.append(digit)
            if pin.count == 6 {
                verifyPin()
            }
        }
    }

    private func deleteDigit() {
        if !pin.isEmpty {
            pin.removeLast()
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

// Reusable iOS Phone App Style Button
struct LiquidKeypadButton: View {
    let number: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Circular button matching iOS Phone Keypad (Light Gray on White)
                Circle()
                    .fill(Color.gray.opacity(0.2))

                Text(number)
                    .font(.system(size: 36, weight: .regular))
                    .foregroundColor(.black)
            }
            .frame(width: 78, height: 78)
        }
    }
}

// Helper for Shake Animation
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX:
                    amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
    }
}

extension View {
    func shake(_ trigger: Binding<Bool>) -> some View {
        self.modifier(ShakeModifier(trigger: trigger))
    }
}

struct ShakeModifier: ViewModifier {
    @Binding var trigger: Bool
    @State private var animatableData: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: animatableData))
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.default) {
                        animatableData = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        animatableData = 0
                        trigger = false
                    }
                }
            }
    }
}
