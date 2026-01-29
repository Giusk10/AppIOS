import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                Color.spendyBackground.ignoresSafeArea()

                VStack(spacing: 30) {
                    if let user = authManager.currentUser {
                        // User Setup
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.spendyPrimary.opacity(0.1))
                                    .frame(width: 100, height: 100)

                                Text(user.initials)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.spendyGradient)
                            }

                            VStack(spacing: 8) {
                                Text(user.fullName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.spendyText)

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
                        }
                        .padding(.top, 40)
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
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.spendyRed)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundColor(.spendyPrimary)
                }
            }
        }
    }
}
