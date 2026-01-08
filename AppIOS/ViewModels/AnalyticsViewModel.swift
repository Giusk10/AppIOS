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
    typealias MonthlyMetric = monthlyMetric
    
    struct CategoryMetric: Identifiable {
        var id: String { name }
        let name: String
        let amount: Double
        let count: Int
    }
    
    // Filter State
    @Published var filterMode: FilterMode = .all
    @Published var selectedDateRange: (start: Date, end: Date) = (Date(), Date())
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var selectedYearInt: Int = Calendar.current.component(.year, from: Date())
    
    enum FilterMode {
        case all
        case month
        case dateRange
    }
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let expenses = try await ExpenseService.shared.fetchExpenses()
                await MainActor.run {
                    processExpenses(expenses)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to load data: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func applyFilters() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                var expenses: [Expense] = []
                
                switch filterMode {
                case .all:
                    expenses = try await ExpenseService.shared.fetchExpenses()
                case .month:
                    expenses = try await ExpenseService.shared.fetchExpensesByMonth(month: selectedMonth, year: selectedYearInt)
                case .dateRange:
                    expenses = try await ExpenseService.shared.fetchExpensesByDate(start: selectedDateRange.start, end: selectedDateRange.end)
                }
                
                await MainActor.run {
                    processExpenses(expenses)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to load expenses: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func processExpenses(_ expenses: [Expense]) {
        let outflows = expenses.filter { $0.amount < 0 }
        
        // 1. Calculate Summaries
        let totalSpending = outflows.reduce(0) { $0 + abs($1.amount) }
        self.totalBalance = totalSpending
        
        self.totalTransactions = outflows.count
        self.averageExpense = outflows.isEmpty ? 0 : totalSpending / Double(outflows.count)
        self.highestExpense = outflows.map { abs($0.amount) }.max() ?? 0.0
        
        // 2. Categories
        var categoryMap: [String: (Double, Int)] = [:]
        for expense in outflows {
            let cat = expense.category ?? "Uncategorized"
            let existing = categoryMap[cat] ?? (0.0, 0)
            categoryMap[cat] = (existing.0 + abs(expense.amount), existing.1 + 1)
        }
        
        self.topCategories = categoryMap.map { key, value in
            CategoryMetric(name: key, amount: value.0, count: value.1)
        }.sorted(by: { $0.amount > $1.amount })
        
        // 3. Chart Data (Dynamic based on Filter)
        generateChartData(from: outflows)
    }
    
    private func generateChartData(from expenses: [Expense]) {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        var chartPoints: [MonthlyMetric] = []
        var groupedExpenses: [Date: Double] = [:]
        
        // Determine grouping strategy
        let isDaily = (filterMode == .month || filterMode == .dateRange)
        
        // Date Parsing Helper
        let parseDate: (String) -> Date? = { dateString in
            // Try standard formats
            let formats = ["yyyy-MM-dd", "dd/MM/yyyy", "yyyy-MM-dd HH:mm:ss"]
            for format in formats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) { return date }
            }
            return nil
        }
        
        for expense in expenses {
            if let dateStr = expense.startedDate, let fullDate = parseDate(dateStr) {
                let keyDate: Date
                if isDaily {
                    // Group by Day (Strip time)
                    let components = calendar.dateComponents([.year, .month, .day], from: fullDate)
                    keyDate = calendar.date(from: components) ?? fullDate
                } else {
                    // Group by Month (First day of month)
                    let components = calendar.dateComponents([.year, .month], from: fullDate)
                    keyDate = calendar.date(from: components) ?? fullDate
                }
                
                groupedExpenses[keyDate, default: 0] += abs(expense.amount)
            }
        }
        
        // Sort keys and create metrics
        let sortedKeys = groupedExpenses.keys.sorted()
        
        if isDaily {
             dateFormatter.dateFormat = "dd" // Day number
        } else {
             dateFormatter.dateFormat = "MMM" // Month name
        }
        
        for date in sortedKeys {
            if let amount = groupedExpenses[date] {
                let label = dateFormatter.string(from: date)
                chartPoints.append(MonthlyMetric(month: label, amount: amount, date: date))
            }
        }
        
        self.monthlyData = chartPoints
    }
    
    // Legacy/Comparison method - can keep or remove if we rely fully on local agg
    func fetchMonthlyStats(year: String) {
        // Only fetch if we really want server side stats for the whole year specifically
        // usage in updateFilters calls this.
        
        Task {
            if let amounts = await ExpenseService.shared.getMonthlyStats(year: year) {
                await MainActor.run {
                    self.monthlyData = processMonthlyStats(amounts, year: year)
                }
            }
        }
    }
    
    private func processMonthlyStats(_ amounts: [Double], year: String) -> [MonthlyMetric] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let calendar = Calendar.current
        var metrics: [MonthlyMetric] = []
        
        for (index, amount) in amounts.enumerated() {
            var components = DateComponents()
            components.year = Int(year)
            components.month = index + 1 // 1-based
            components.day = 1
            
            if let date = calendar.date(from: components) {
                let monthName = dateFormatter.string(from: date)
                metrics.append(MonthlyMetric(month: monthName, amount: amount, date: date))
            }
        }
        
        return metrics
    }
    
    func updateFilters(year: String) {
        fetchMonthlyStats(year: year)
        selectedYearInt = Int(year) ?? selectedYearInt
    }
}
