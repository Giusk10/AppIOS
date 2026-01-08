import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var description: String = ""
    @State private var amount: Double = 0.0
    @State private var date: Date = Date()
    @State private var category: String = "General"
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Simple predefined categories
    let categories = ["General", "Food", "Transport", "Shopping", "Entertainment", "Bills", "Health"]

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Description", text: $description)
                
                TextField("Amount", value: $amount, format: .currency(code: "EUR"))
                    .keyboardType(.decimalPad)
                
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) {
                        Text($0)
                    }
                }
            }
            
            Section(header: Text("Date")) {
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            
            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("New Expense")
        .disabled(isLoading)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if isLoading {
                    ProgressView()
                } else {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(description.isEmpty || amount == 0)
                }
            }
        }
    }
    
    private func saveExpense() {
        isLoading = true
        errorMessage = nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        // Ensure negative amount for expense if user enters positive
        // Though user might enter negative. Let's assume standard is negative.
        // User enters 10 -> -10. User enters -10 -> -10.
        let finalAmount = -abs(amount)
        
        let expense = Expense(
            type: "Manual",
            product: "Manual",
            startedDate: dateString,
            completedDate: dateString,
            description: description,
            amount: finalAmount,
            category: category
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
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                }
            }
        }
    }
}
