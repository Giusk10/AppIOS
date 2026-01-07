import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.startedDate, order: .reverse) private var expenses: [Expense]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(expenses) { expense in
                    VStack(alignment: .leading) {
                        Text(expense.userDescription)
                            .font(.headline)
                        HStack {
                            Text(expense.amount, format: .currency(code: expense.currency ?? "EUR"))
                            Spacer()
                            Text(expense.state ?? "")
                                .font(.caption)
                                .padding(4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                        if let date = expense.startedDate {
                            Text(date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: UploadView()) {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .onAppear {
                 ExpenseService.shared.setModelContext(modelContext)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(expenses[index])
            }
        }
    }
}
