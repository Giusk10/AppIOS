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
    @State private var animateContent = false

    var categoryColor: Color {
        CategoryMapper.color(for: expense.category)
    }

    var categoryIcon: String {
        CategoryMapper.icon(for: expense.category)
    }

    var body: some View {
        ZStack {
            Color.spendyBackground
                .ignoresSafeArea()

            Color.spendyMeshGradient
                .opacity(0.12)
                .ignoresSafeArea()
                .blur(radius: 40)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    amountHeader
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                    detailsCard
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)

                    if isEditing {
                        saveButton
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    deleteButton
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)
                }
                .padding(24)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Dettaglio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isEditing.toggle()
                    }
                }) {
                    Image(systemName: isEditing ? "xmark.circle.fill" : "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            isEditing
                                ? AnyShapeStyle(Color.spendySecondaryText)
                                : AnyShapeStyle(Color.spendyGradient))
                }
            }
        }
        .onAppear {
            initializeFields()
            withAnimation(.easeOut(duration: 0.5)) {
                animateContent = true
            }
        }
    }

    private var amountHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.08))
                    .frame(width: 80, height: 80)

                Image(systemName: categoryIcon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(categoryColor)
                    .shadow(color: categoryColor.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 10)

            VStack(spacing: 6) {
                if isEditing {
                    TextField("Cosa hai comprato?", text: $description)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.spendySecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .accentColor(Color.spendyPrimary)
                } else {
                    Text(description.isEmpty ? "Spesa senza nome" : description.uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.spendyTertiaryText)
                }

                if isEditing {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("€")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.spendyText)

                        TextField(
                            "0.00", value: $amount, format: .number.precision(.fractionLength(2))
                        )
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.spendyText)
                        .keyboardType(.decimalPad)
                        .fixedSize()
                        .accentColor(Color.spendyPrimary)
                    }
                } else {
                    Text(abs(amount), format: .currency(code: expense.currency ?? "EUR"))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.spendyText)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var detailsCard: some View {
        VStack(spacing: 20) {
            // Data e Ora
            HStack(spacing: 16) {
                Image(systemName: "calendar")
                    .foregroundColor(Color.spendyAccent)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text("DATA E ORA")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.spendyTertiaryText)

                    if isEditing {
                        DatePicker("", selection: $startedDate)
                            .labelsHidden()
                            .accentColor(Color.spendyPrimary)
                    } else {
                        Text(startedDate.formattedDescription(withTime: true))
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.spendyText)
                    }
                }
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 2)

            // Categoria (sempre visibile se presente)
            if let cat = expense.category {
                HStack(spacing: 16) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(categoryColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("CATEGORIA")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.spendyTertiaryText)

                        Text(cat)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(categoryColor)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 2)
            }

            // Metodo
            HStack(spacing: 16) {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.spendyPrimary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text("METODO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.spendyTertiaryText)

                    if isEditing {
                        Picker("", selection: $type) {
                            Text("Carta").tag("Carta")
                            Text("Pagamento con carta").tag("Pagamento con carta")
                            Text("Ricarica").tag("Ricarica")
                            Text("Manuale").tag("Manuale")
                        }
                        .pickerStyle(.menu)
                        .tint(.spendyPrimary)
                        .offset(x: -8)
                    } else {
                        Text(type == "Pagamento con carta" ? "Carta" : type)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.spendyText)
                    }
                }
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 2)
        }
    }

    private var saveButton: some View {
        Button(action: updateExpense) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                Text("Salva Modifiche")
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
    }

    private var deleteButton: some View {
        Button(action: deleteExpense) {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                Text("Elimina transazione")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.spendyRed.opacity(0.8))
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 8)
    }

    private func initializeFields() {
        description = expense.userDescription
        amount = expense.amount
        category = expense.category ?? ""
        category = expense.category ?? ""
        if ["Pagamento con carta", "Carta", "Ricarica", "Manuale", "Contanti"].contains(
            expense.type)
        {
            type = expense.type
        } else {
            type = "Manuale"
        }
        product = expense.product

        if let dateStr = expense.startedDateString {
            startedDate = parseDate(from: dateStr) ?? Date()
        }
    }

    private func parseDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd",
            "dd/MM/yyyy HH:mm:ss",
            "dd/MM/yyyy",
        ]

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }

    private func updateExpense() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: startedDate)

        let updatedExpense = Expense(
            id: expense.id,
            type: type,
            product: product,
            startedDate: dateString,
            completedDate: dateString,
            description: description,
            amount: amount,
            fee: expense.fee,
            currency: expense.currency,
            state: expense.state,
            category: category
        )

        Task {
            do {
                try await ExpenseService.shared.updateExpense(updatedExpense)
                dismiss()
            } catch {
                print("Error updating expense: \(error)")
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

struct DetailRow<Content: View>: View {
    let label: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.spendySecondaryText)
                    .frame(width: 20)

                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.spendySecondaryText)
            }

            Spacer()

            content
        }
    }
}
