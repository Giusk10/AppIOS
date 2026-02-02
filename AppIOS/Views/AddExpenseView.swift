import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss

    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var type: String = "Carta"
    @State private var isLoading = false
    @State private var errorMessage: String?

    let expenseTypes = ["Carta", "Contanti"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.spendyBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header con Importo
                        amountSection

                        VStack(spacing: 16) {
                            // Form Dettagli
                            detailsSection

                            if let error = errorMessage {
                                errorBanner(error)
                            }

                            saveButton
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Nuova Spesa")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var amountSection: some View {
        VStack(spacing: 12) {
            Text("QUANTO HAI SPESO?")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.spendySecondaryText)
                .tracking(1.2)

            HStack(alignment: .center, spacing: 12) {
                Text("€")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.spendyText)

                TextField("0.00", text: $amount)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.spendyText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
                    .fixedSize()
            }
        }
        .padding(.vertical, 20)
    }

    private var detailsSection: some View {
        VStack(spacing: 0) {
            // Descrizione
            VStack(alignment: .leading, spacing: 12) {
                Label("Descrizione", systemImage: "pencil.line")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.spendySecondaryText)

                TextField("Cosa hai acquistato?", text: $description)
                    .font(.body)
                    .padding(16)
                    .background(Color.spendyBackground)
                    .cornerRadius(12)
            }
            .padding(20)

            Divider().padding(.horizontal, 20)

            // Data e Ora
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(.spendySecondaryText)

                Spacer(minLength: 16)

                DatePicker("", selection: $date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .accentColor(.spendyPrimary)
            }
            .padding(20)

            Divider().padding(.horizontal, 20)

            // Tipo
            HStack {
                Image(systemName: "creditcard")
                    .font(.system(size: 20))
                    .foregroundColor(.spendySecondaryText)

                Spacer(minLength: 16)

                Picker("Tipo", selection: $type) {
                    ForEach(expenseTypes, id: \.self) { expenseType in
                        Text(expenseType)
                            .tag(expenseType)
                    }
                }
                .pickerStyle(.menu)
                .tint(.spendyPrimary)
                .labelsHidden()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
            .padding(20)
        }
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.03), radius: 15, x: 0, y: 5)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.spendyRed)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.spendyRed)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spendyRed.opacity(0.1))
        .cornerRadius(12)
    }

    private var saveButton: some View {
        Button(action: saveExpense) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("Aggiungi Spesa")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                canSave && !isLoading
                    ? AnyView(Color.spendyGradient)
                    : AnyView(Color.gray.opacity(0.3))
            )
            .cornerRadius(18)
            .shadow(
                color: canSave && !isLoading ? Color.spendyPrimary.opacity(0.3) : Color.clear,
                radius: 10, x: 0, y: 5)
        }
        .disabled(!canSave || isLoading)
    }

    private var canSave: Bool {
        !description.isEmpty && !amount.isEmpty
            && (Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }

    private func saveExpense() {
        isLoading = true
        errorMessage = nil

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)

        let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0
        let finalAmount = -abs(amountValue)

        let expense = Expense(
            type: type,
            product: "Manual",
            startedDate: dateString,
            completedDate: dateString,
            description: description,
            amount: finalAmount,
            category: nil
        )

        Task {
            do {
                try await ExpenseService.shared.addExpense(expense)
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Errore nel salvataggio: \(error.localizedDescription)"
                }
            }
        }
    }
}
