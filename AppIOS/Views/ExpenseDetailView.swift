import SwiftUI

struct ExpenseDetailView: View {
    let expense: Expense
    @Environment(\.dismiss) private var dismiss
    
    @State private var description: String = ""
    @State private var amount: Double = 0.0
    @State private var startedDate: Date = Date()
    @State private var category: String = ""
    @State private var type: String = "EXPENSE"
    @State private var product: String = ""
    @State private var isEditing = false
    
    var body: some View {
        ZStack {
            Color.spendyBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 20) {
                        // Header info
                        if isEditing {
                            TextField("Descrizione", text: $description)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.spendyText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else {
                            Text(description.isEmpty ? "Nessuna descrizione" : description)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.spendyText)
                                .multilineTextAlignment(.center)
                        }
                        
                        if isEditing {
                            TextField("Importo", value: $amount, format: .currency(code: expense.currency ?? "EUR"))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(amount >= 0 ? .spendyGreen : .spendyText)
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                        } else {
                            Text(amount, format: .currency(code: expense.currency ?? "EUR"))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(amount >= 0 ? .spendyGreen : .spendyText)
                        }
                        
                        Divider()
                        
                        // Details Grid
                        VStack(spacing: 16) {
                            HStack {
                                Text("Data")
                                    .foregroundColor(.spendySecondaryText)
                                Spacer()
                                if isEditing {
                                    DatePicker("", selection: $startedDate, displayedComponents: [.date, .hourAndMinute])
                                        .labelsHidden()
                                } else {
                                    Text(startedDate.formatted(date: .numeric, time: .shortened))
                                        .fontWeight(.medium)
                                        .foregroundColor(.spendyText)
                                }
                            }
                            
                            if let category = expense.category {
                                HStack {
                                    Text("Categoria")
                                        .foregroundColor(.spendySecondaryText)
                                    Spacer()
                                    Text(category)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.spendyPrimary.opacity(0.1))
                                        .foregroundColor(.spendyPrimary)
                                        .cornerRadius(8)
                                }
                            }
                            
                            HStack {
                                Text("Tipo")
                                    .foregroundColor(.spendySecondaryText)
                                Spacer()
                                if isEditing {
                                    Picker("Tipo", selection: $type) {
                                        Text("Pagamento con carta").tag("Pagamento con carta")
                                        Text("Ricarica").tag("Ricarica")
                                        Text("Manuale").tag("Manuale")
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(.spendyPrimary)
                                    .fixedSize(horizontal: true, vertical: false)
                                } else {
                                    Text(type)
                                        .fontWeight(.medium)
                                        .foregroundColor(.spendyText)
                                }
                            }

                            if !expense.product.isEmpty {
                                HStack {
                                    Text("Prodotto")
                                        .foregroundColor(.spendySecondaryText)
                                    Spacer()
                                    Text(expense.product)
                                        .multilineTextAlignment(.trailing)
                                        .fontWeight(.medium)
                                        .foregroundColor(.spendyText)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    if isEditing {
                        Button(action: updateExpense) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Salva Modifiche")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.spendyPrimary)
                            .cornerRadius(12)
                            .shadow(color: Color.spendyPrimary.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    
                    // Only show delete when not editing? Or always?
                    // User request: "appena viene cliccato i campi diventano modificabili altrimenti sono fissi"
                    // Usually delete is always available, but let's keep it clean.
                    
                    Button(action: deleteExpense) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Elimina Spesa")
                        }
                        .foregroundColor(.spendyRed)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.spendyRed.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Dettaglio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing.toggle() }) {
                    Image(systemName: isEditing ? "xmark.circle" : "pencil")
                        .foregroundColor(.spendyPrimary)
                }
            }
        }
        .onAppear {
            initializeFields()
        }
    }
    
    private func initializeFields() {
        description = expense.userDescription
        amount = expense.amount
        category = expense.category ?? ""
        if ["Pagamento con carta", "Ricarica", "Manuale"].contains(expense.type) {
            type = expense.type
        } else {
            type = "Manuale"
        }
        product = expense.product
        
        if let dateStr = expense.startedDate {
            print("DEBUG: Parsing date string: '\(dateStr)'")
            startedDate = parseDate(from: dateStr) ?? Date()
        }
    }
    
    private func parseDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        // Formats to try, prioritized
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd",
            "dd/MM/yyyy HH:mm:ss",
            "dd/MM/yyyy"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        print("DEBUG: Failed to parse date string: '\(string)'")
        return nil
    }
    
    private func updateExpense() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var updatedExpense = expense
        updatedExpense.userDescription = description
        updatedExpense.amount = amount
        updatedExpense.startedDate = formatter.string(from: startedDate)
        // Set completedDate to same as startedDate logic or keep original? user said "startedDate" and "completedDate" in curl.
        // Assuming completedDate tracks the same or logic is maintained. I will update startedDate.
         updatedExpense.completedDate = formatter.string(from: startedDate) // Keeping consistent or optional? logic check
        updatedExpense.category = category
        updatedExpense.type = type
        updatedExpense.product = product
        
        Task {
            do {
                try await ExpenseService.shared.updateExpense(updatedExpense)
                dismiss()
            } catch {
                print("Error updating expense: \(error)")
                // Handle error alert if needed
            }
        }
    }
    
    private func deleteExpense() {
        Task {
            try? await ExpenseService.shared.deleteExpense(expense)
            dismiss()
        }
    }
}


