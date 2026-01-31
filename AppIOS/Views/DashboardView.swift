import SwiftUI

class DateFormatterCache {
    static let shared = DateFormatterCache()

    let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Supporta i formati più comuni
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    let outputTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()

    let outputFullFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()
}

extension String {
    // Versione ottimizzata che usa i formatter in cache
    func formattedDateOptimized(withTime: Bool = false) -> String {
        // Tenta di parsare con il formatter principale (ISO)
        // Nota: Se hai formati diversi in input, dovresti normalizzare il backend o il parsing nel ViewModel
        guard let date = DateFormatterCache.shared.isoFormatter.date(from: self) else {
            // Fallback veloce se non è ISO standard (per evitare crash)
            return "Data non valida"
        }

        let calendar = Calendar.current
        let timeString = DateFormatterCache.shared.outputTimeFormatter.string(from: date)

        if calendar.isDateInToday(date) {
            return "Oggi, \(timeString)"
        } else if calendar.isDateInYesterday(date) {
            return "Ieri, \(timeString)"
        } else {
            if withTime {
                return DateFormatterCache.shared.outputFullFormatter.string(from: date)
            } else {
                return DateFormatterCache.shared.outputDateFormatter.string(from: date)
            }
        }
    }
}

// ---------------------------------------------------------
// 2. VIEW PRINCIPALE
// ---------------------------------------------------------

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject private var authManager = AuthManager.shared

    @State private var showingDeleteAlert = false
    @State private var showingProfile = false
    @State private var selectedFilter: TransactionFilter = .all

    enum TransactionFilter: String, CaseIterable {
        case all = "Tutte"
        case income = "Entrate"
        case expenses = "Uscite"
    }

    // Nota: Idealmente questi calcoli dovrebbero stare nel ViewModel ed essere variabili @Published
    // per evitare di ricalcolare ad ogni render della view.
    var filteredExpenses: [Expense] {
        switch selectedFilter {
        case .all: return viewModel.expenses
        case .income: return viewModel.expenses.filter { $0.amount > 0 }
        case .expenses: return viewModel.expenses.filter { $0.amount < 0 }
        }
    }

    var totalBalance: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.spendyBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {  // Spaziatura aumentata per "aria"
                        balanceCard
                            .padding(.top, 10)

                        filterSection

                        if let errorMessage = viewModel.errorMessage {
                            errorBanner(errorMessage)
                        }

                        recentTransactionsSection

                        uploadSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            // Usa .task invece di .onAppear per concorrenza automatica
            .task {
                viewModel.fetchExpenses()
                await AuthManager.shared.fetchUserProfile()
            }
            .toolbar {
                leadingToolbarItem
                principalToolbarItem
                trailingToolbarItem
            }
        }
        .alert("Elimina tutte le spese", isPresented: $showingDeleteAlert) {
            Button("Annulla", role: .cancel) {}
            Button("Elimina", role: .destructive) {
                viewModel.deleteAllExpenses()
            }
        } message: {
            Text(
                "Sei sicuro di voler eliminare tutte le spese? Questa azione non può essere annullata."
            )
        }
        .sheet(isPresented: $showingProfile) {
            UserProfileView()
        }
    }

    // MARK: - Componenti UI Estratti

    private var balanceCard: some View {
        VStack(spacing: 0) {
            ZStack {
                // Sfondo ottimizzato
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.spendyPrimary, Color.spendyAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Elementi decorativi statici
                decorativeCircles

                VStack(spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Saldo Totale")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))

                            Text(totalBalance, format: .currency(code: "EUR"))
                                .font(.system(size: 34, weight: .bold, design: .rounded))  // Font leggermente ridotto
                                .foregroundColor(.white)
                                .contentTransition(.numericText())
                        }
                        Spacer()

                        // Icona trend
                        trendIcon
                    }

                    statsRow
                }
                .padding(24)
            }
            .frame(height: 200)
            // Disegna il contenuto come una bitmap off-screen (GPU acceleration)
            .drawingGroup()
        }
    }

    private var decorativeCircles: some View {
        Group {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 200)
                .offset(x: 100, y: -50)
                .blur(radius: 1)  // Blur leggero per fondere meglio

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 150)
                .offset(x: -120, y: 60)
                .blur(radius: 1)
        }
    }

    private var trendIcon: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .frame(width: 44, height: 44)  // Ridotto leggermente
            .overlay {
                Image(systemName: totalBalance >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {  // Spacing gestito dai frame interni
            StatItem(
                title: "Entrate",
                // Calcolo ottimizzato (meglio spostarlo nel VM)
                value: viewModel.expenses.lazy.filter { $0.amount > 0 }.reduce(0) {
                    $0 + $1.amount
                },
                icon: "arrow.down.left",
                positive: true
            )

            Divider()
                .frame(height: 30)
                .background(Color.white.opacity(0.3))
                .padding(.horizontal, 16)

            StatItem(
                title: "Uscite",
                value: abs(
                    viewModel.expenses.lazy.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }),
                icon: "arrow.up.right",
                positive: false
            )
        }
    }

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter,
                        action: {
                            withAnimation(.smooth(duration: 0.3)) {  // Animazione più rapida
                                selectedFilter = filter
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 4)  // Evita clipping dell'ombra
        }
    }

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Transazioni Recenti")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.spendyText)

                Spacer()

                NavigationLink(destination: AllExpensesView()) {
                    HStack(spacing: 4) {
                        Text("Vedi tutte")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.spendyGradient)
                }
            }

            if filteredExpenses.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 0) {  // LazyVStack è meglio per performance anche se sono pochi elementi
                    // Prendiamo max 4 elementi senza creare array intermedi pesanti
                    ForEach(Array(filteredExpenses.prefix(4)), id: \.id) { expense in
                        NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                            ExpenseRow(expense: expense)
                                .contentShape(Rectangle())  // Migliora l'area di tocco
                        }
                        .buttonStyle(.plain)

                        // Logica divisore semplificata
                        if expense.id != filteredExpenses.prefix(4).last?.id {
                            Divider().padding(.leading, 76)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)  // Ombra alleggerita
            }
        }
    }

    private var uploadSection: some View {
        NavigationLink(destination: UploadView()) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.spendyPrimary.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.spendyGradient)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Importa CSV")
                        .font(.headline)
                        .foregroundColor(.spendyText)

                    Text("Carica transazioni dalla banca")
                        .font(.caption)
                        .foregroundColor(.spendySecondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.spendySecondaryText.opacity(0.5))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toolbar Items (Per pulizia del body)

    private var leadingToolbarItem: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { showingProfile = true }) {
                Group {
                    if let user = authManager.currentUser {
                        Text(user.initials)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                    }
                }
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)  // Ridotto leggermente
                .background(Color.spendyGradient)
                .clipShape(Circle())
            }
        }
    }

    private var principalToolbarItem: ToolbarItem<(), some View> {
        ToolbarItem(placement: .principal) {
            Text("Spendy")
                .font(.system(size: 18, weight: .bold, design: .rounded))  // Ridotto per eleganza
                .foregroundStyle(Color.spendyGradient)
        }
    }

    private var trailingToolbarItem: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 8) {
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.spendyRed.opacity(viewModel.expenses.isEmpty ? 0.3 : 0.9))
                }
                .disabled(viewModel.expenses.isEmpty)

                NavigationLink(destination: AddExpenseView()) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.spendyGradient)
                        .symbolRenderingMode(.hierarchical)  // Render più moderno
                }
            }
        }
    }

    // Funzioni helper rimaste uguali ma spostate per pulizia
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.spendyOrange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.spendyText)
            Spacer()
        }
        .padding()
        .background(Color.spendyOrange.opacity(0.1))
        .cornerRadius(12)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(Color.spendyGradient.opacity(0.8))

            Text("Nessuna transazione")
                .font(.headline)
                .foregroundColor(.spendyText)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(Color.white.opacity(0.5))  // Più leggero
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

// ---------------------------------------------------------
// 3. COMPONENTI SECONDARI OTTIMIZZATI
// ---------------------------------------------------------

struct ExpenseRow: View {
    let expense: Expense

    // Cache di valori computati semplici
    private var categoryColor: Color { CategoryMapper.color(for: expense.category) }
    private var categoryIcon: String { CategoryMapper.icon(for: expense.category) }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.12))  // Opacità ridotta per look più clean
                    .frame(width: 44, height: 44)

                Image(systemName: categoryIcon)
                    .font(.system(size: 18, weight: .medium))  // Font weight ridotto
                    .foregroundColor(categoryColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(expense.userDescription)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.spendyText)
                    .lineLimit(1)

                if let date = expense.startedDateString {
                    // QUI SI USA LA FUNZIONE OTTIMIZZATA
                    Text(date.formattedDateOptimized(withTime: true))
                        .font(.caption2)  // Testo più piccolo e discreto
                        .foregroundColor(.spendySecondaryText)
                }
            }

            Spacer()

            Text(expense.amount, format: .currency(code: expense.currency ?? "EUR"))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(expense.amount >= 0 ? .spendyGreen : .spendyText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// StatItem e FilterChip ottimizzati per contrasto e dimensione
struct StatItem: View {
    let title: String
    let value: Double
    let icon: String
    let positive: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundColor(.white.opacity(0.7))
                Text(value, format: .currency(code: "EUR"))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .spendySecondaryText)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Color.spendyGradient)
                    } else {
                        Capsule()
                            .fill(Color.white)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
