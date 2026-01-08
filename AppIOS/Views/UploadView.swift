import SwiftUI
import UniformTypeIdentifiers

struct UploadView: View {
    @State private var isImporting: Bool = false
    @State private var message: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Import Expenses")
                .font(.title)
            
            Button("Select CSV File") {
                isImporting = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text(message)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                
                if selectedFile.startAccessingSecurityScopedResource() {
                    defer { selectedFile.stopAccessingSecurityScopedResource() }
                    
                    message = "Uploading..."
                    Task {
                        do {
                            let success = try await ExpenseService.shared.importCSV(url: selectedFile)
                            await MainActor.run {
                                message = success ? "Upload successful!" : "Upload failed."
                            }
                        } catch {
                            await MainActor.run {
                                message = "Error: \(error.localizedDescription)"
                            }
                        }
                    }
                } else {
                    message = "Permission denied to access file."
                }
            } catch {
                message = "Error: \(error.localizedDescription)"
            }
        }
        .navigationTitle("Import")
    }
}
