import SwiftUI
import UniformTypeIdentifiers

struct UploadView: View {
    @State private var isImporting: Bool = false
    @State private var message: String = ""
    @State private var isSuccess: Bool = false
    @State private var isLoading: Bool = false
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            Color.spendyBackground
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.spendyPrimary.opacity(0.08))
                .frame(width: 400)
                .blur(radius: 80)
                .offset(x: 100, y: -200)
            
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.spendyPrimary.opacity(0.15), Color.spendyAccent.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundStyle(Color.spendyGradient)
                    }
                    .scaleEffect(animateContent ? 1 : 0.8)
                    .opacity(animateContent ? 1 : 0)
                    
                    VStack(spacing: 12) {
                        Text("Importa Spese")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.spendyText)
                        
                        Text("Carica il tuo file CSV per importare\nautomaticamente le transazioni")
                            .font(.body)
                            .foregroundColor(.spendySecondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                }
                
                VStack(spacing: 16) {
                    Button(action: {
                        isImporting = true
                    }) {
                        HStack(spacing: 12) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            Text(isLoading ? "Caricamento..." : "Seleziona File CSV")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.spendyGradient)
                        .cornerRadius(16)
                        .shadow(color: Color.spendyPrimary.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 40)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                    
                    if !message.isEmpty {
                        HStack(spacing: 12) {
                            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(isSuccess ? .spendyGreen : .spendyRed)
                            
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(isSuccess ? .spendyGreen : .spendyRed)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background((isSuccess ? Color.spendyGreen : Color.spendyRed).opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                        Text("Formati supportati: CSV")
                            .font(.caption)
                    }
                    .foregroundColor(.spendyTertiaryText)
                }
                .padding(.bottom, 120)
                .opacity(animateContent ? 1 : 0)
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .navigationTitle("Importa")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateContent = true
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            guard let selectedFile: URL = try result.get().first else { return }
            
            if selectedFile.startAccessingSecurityScopedResource() {
                defer { selectedFile.stopAccessingSecurityScopedResource() }
                
                do {
                    let data = try Data(contentsOf: selectedFile)
                    let fileName = selectedFile.lastPathComponent
                    
                    isLoading = true
                    withAnimation {
                        message = ""
                    }
                    
                    Task {
                        do {
                            let success = try await ExpenseService.shared.importCSV(data: data, fileName: fileName)
                            await MainActor.run {
                                isLoading = false
                                isSuccess = success
                                withAnimation(.spring()) {
                                    message = success ? "Upload completato con successo!" : "Upload fallito."
                                }
                            }
                        } catch {
                            await MainActor.run {
                                isLoading = false
                                isSuccess = false
                                withAnimation(.spring()) {
                                    message = "Errore: \(error.localizedDescription)"
                                }
                            }
                        }
                    }
                } catch {
                    message = "Impossibile accedere ai dati del file"
                    isSuccess = false
                }
            } else {
                message = "Permesso negato per accedere al file"
                isSuccess = false
            }
        } catch {
            message = "Errore: \(error.localizedDescription)"
            isSuccess = false
        }
    }
}
