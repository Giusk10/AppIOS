import Foundation
import Combine

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var totalBalance: Double = 0.0
    @Published var averageExpense: Double = 0.0
    @Published var highestExpense: Double = 0.0
    @Published var totalTransactions: Int = 0
    @Published var monthlyData: [MonthlyMetric] = []
    @Published var topCategories: [CategoryMetric] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    struct monthlyMetric: Identifiable {
        var id: String { month }
        let month: String
        let amount: Double
        let date: Date // For sorting
    }
    
    // Alias to fix capitalization for public use if preferred, but struct above is internal helper
    typealias MonthlyMetric = monthlyMetric
    
    struct CategoryMetric: Identifiable {
        var id: String { name }
        let name: String
        let amount: Double
        let count: Int
    }
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let expenses = try await ExpenseService.shared.fetchExpenses()
                processExpenses(expenses)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Failed to load data: \(error.localizedDescription)"
            }
        }
    }
    
    private func processExpenses(_ expenses: [Expense]) {
        // Filter valid expenses (ignore those without amount etc if any, though model enforces it)
        // Expenses are usually negative for spending? 
        // User screenshot shows positive numbers for "USCITE".
        // Our AddExpense uses negative. Dashboard shows green/red.
        // Let's assume we want to show absolute values for "Spending" analysis,
        // or just sum them up. 
        // Screenshot: "Uscite Totali: 847,41 €". "Uscita Maggiore: 247,00 €".
        // This implies we look at the magnitude of negative numbers (outflows).
        
        let outflows = expenses.filter { $0.amount < 0 }
        
        // 1. Total Balance (Balance implies net, but "Uscite Totali" implies User wants total spending)
        // However, "Total Balance" in dashboard is net.
        // The request says "grafico e statistiche come nel mio sito" and attaches image of "Uscite Totali".
        // So I will implement "Total Spending" (sum of abs(negative)).
        
        let totalSpending = outflows.reduce(0) { $0 + abs($1.amount) }
        self.totalBalance = totalSpending
        
        self.totalTransactions = outflows.count
        
        // 2. Average
        self.averageExpense = outflows.isEmpty ? 0 : totalSpending / Double(outflows.count)
        
        // 3. Highest
        self.highestExpense = outflows.map { abs($0.amount) }.max() ?? 0.0
        
        // 4. Monthly Trend
        // Group by Month-Year
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Input format
        // We might need to handle HH:mm:ss too
        
        var monthlyMap: [String: Double] = [:]
        var monthlyDateMap: [String: Date] = [:]
        
        for expense in outflows {
            // Try parse date
            var date: Date? = nil
            
            // Try multiple formats
            let formats = [
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd",
                "dd/MM/yyyy",
                "dd-MM-yyyy",
                "yyyy/MM/dd"
            ]
            
            if let dStr = expense.startedDate {
                for format in formats {
                    dateFormatter.dateFormat = format
                    if let d = dateFormatter.date(from: dStr) {
                        date = d
                        break
                    }
                }
            }
            
            if let d = date {
                // Key: "Jan", "Feb" etc. But we need correct order. using First day of month date as key helper
                let components = calendar.dateComponents([.year, .month], from: d)
                if let monthDate = calendar.date(from: components) {
                     let key = ISO8601DateFormatter().string(from: monthDate)
                     monthlyMap[key, default: 0] += abs(expense.amount)
                     monthlyDateMap[key] = monthDate
                }
            }
        }
        
        // Fill gaps? Optional. For now let's just show what we have or sorted.
        let sortedKeys = monthlyMap.keys.sorted()
        self.monthlyData = sortedKeys.compactMap { key -> MonthlyMetric? in
            guard let amount = monthlyMap[key], let date = monthlyDateMap[key] else { return nil }
            // Format month name
            let f = DateFormatter()
            f.dateFormat = "MMM"
            return MonthlyMetric(month: f.string(from: date), amount: amount, date: date)
        }.sorted(by: { $0.date < $1.date })
        
        
        // 5. Categories
        var categoryMap: [String: (Double, Int)] = [:]
        for expense in outflows {
            let cat = expense.category ?? "Uncategorized"
            let existing = categoryMap[cat] ?? (0.0, 0)
            categoryMap[cat] = (existing.0 + abs(expense.amount), existing.1 + 1)
        }
        
        self.topCategories = categoryMap.map { key, value in
            CategoryMetric(name: key, amount: value.0, count: value.1)
        }.sorted(by: { $0.amount > $1.amount })
    }
}
