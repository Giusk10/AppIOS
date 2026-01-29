import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared

    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.spendyBackground.ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer().frame(height: 20)  // Add top spacing as requested

                    if let user = authManager.currentUser {
                        // User Setup
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.spendyPrimary.opacity(0.1))
                                    .frame(width: 100, height: 100)

                                Text(user.initials)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.spendyGradient)
                            }

                            VStack(spacing: 16) {
                                // Editable Fields
                                VStack(spacing: 12) {
                                    CustomTextField(
                                        icon: "person", placeholder: "Nome", text: $name)
                                    CustomTextField(
                                        icon: "person", placeholder: "Cognome", text: $surname)
                                }
                                .padding(.horizontal, 20)

                                // Read-only info
                                VStack(spacing: 4) {
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.spendySecondaryText)

                                    Text("@\(user.username)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color.spendyPrimary.opacity(0.1))
                                        .cornerRadius(8)
                                        .foregroundColor(.spendyPrimary)
                                }

                                Button(action: {
                                    saveProfile()
                                }) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Salva Modifiche")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    hasChanges(user: user)
                                        ? AnyView(Color.spendyGradient)
                                        : AnyView(Color.gray.opacity(0.3))
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                                .disabled(!hasChanges(user: user) || isLoading)
                                .animation(.easeInOut, value: hasChanges(user: user))
                            }
                        }
                        .padding(.top, 20)
                    } else {
                        ProgressView()
                            .onAppear {
                                Task {
                                    await authManager.fetchUserProfile()
                                }
                            }
                    }

                    Spacer()

                    // Logout Button
                    Button(action: {
                        authManager.logout()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Esci")
                        }
                        .font(.headline)
                        .foregroundColor(.spendyRed)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.spendyRed.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }

            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        Task {
                            await authManager.fetchUserProfile()
                            await MainActor.run {
                                dismiss()
                            }
                        }
                    }
                    .foregroundColor(.spendyPrimary)
                }
            }
            .onAppear {
                if let user = authManager.currentUser {
                    name = user.name
                    surname = user.surname
                }
            }
            .onChange(of: authManager.currentUser) { _, newUser in
                if let user = newUser {
                    if !isLoading {
                        name = user.name
                        surname = user.surname
                    }
                }
            }
        }
    }

    private func hasChanges(user: User) -> Bool {
        return name != user.name || surname != user.surname
    }

    private func saveProfile() {
        guard !name.isEmpty, !surname.isEmpty else { return }

        isLoading = true
        Task {
            _ = await authManager.updateProfile(name: name, surname: surname)
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.spendySecondaryText)
            TextField(placeholder, text: $text)
                .foregroundColor(.spendyText)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
