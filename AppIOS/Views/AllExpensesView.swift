import SwiftUI

struct AllExpensesView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: DashboardView.TransactionFilter = .all
    @Environment(\.dismiss) private var dismiss
    
    // Computed Properties for filtering (duplicated logic from Dashboard logic for now)
    var filteredExpenses: [Expense] {
        let expenses = viewModel.expenses
        let filteredByType: [Expense]
        
        switch selectedFilter {
        case .all:
            filteredByType = expenses
        case .income:
            filteredByType = expenses.filter { $0.amount > 0 }
        case .expenses:
            filteredByType = expenses.filter { $0.amount < 0 }
        }
        
        if searchText.isEmpty {
            return filteredByType
        } else {
            return filteredByType.filter { $0.userDescription.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Picker for filters
            Picker("Filtro", selection: $selectedFilter) {
                ForEach(DashboardView.TransactionFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color.white)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.spendyRed)
                    .font(.caption)
                    .padding()
            }
            
            List {
                ForEach(filteredExpenses) { expense in
                    ExpenseCard(expense: expense)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteExpense(expense)
                            } label: {
                                Label("Elimina", systemImage: "trash")
                            }
                            .tint(.spendyRed)
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .refreshable {
                viewModel.fetchExpenses()
            }
        }
        .background(Color.spendyBackground.ignoresSafeArea())
        .navigationTitle("Tutte le spese")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Cerca spese")
        .onAppear {
            viewModel.fetchExpenses()
        }
    }
}

#Preview {
    NavigationView {
        AllExpensesView()
    }
}
