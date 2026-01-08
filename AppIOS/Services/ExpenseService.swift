import Foundation
import Combine

@MainActor
class ExpenseService {
    static let shared = ExpenseService()
    
    private init() {}
    
    // Removed setModelContext as we don't use SwiftData anymore
    
    func fetchExpenses() async throws -> [Expense] {
         return try await NetworkManager.shared.performRequest(endpoint: "/Expense/rest/expense/getExpenses", responseType: [Expense].self)
    }
    
    func addExpense(_ expense: Expense) async throws {
        // Prepare body for backend
        // Backend expects Map<String, String> as seen in SyncWorker
        let body: [String: String] = [
            "type": expense.type,
            "product": expense.product,
            "startedDate": expense.startedDate ?? "",
            "completedDate": expense.completedDate ?? "",
            "description": expense.userDescription,
            "amount": String(expense.amount),
            "fee": String(expense.fee ?? 0.0),
            "currency": expense.currency ?? "EUR",
            "state": expense.state ?? "",
            "category": expense.category ?? ""
        ]
        
        let _ = try await NetworkManager.shared.performRequest(endpoint: "/Expense/rest/expense/addExpense", method: "POST", body: JSONSerialization.data(withJSONObject: body), responseType: Expense.self)
    }
    
    func deleteExpense(_ expense: Expense) async throws {
         let body = ["expenseId": expense.id]
         try await NetworkManager.shared.performRequestNoResponse(endpoint: "/Expense/rest/expense/deleteExpense", method: "DELETE", body: JSONSerialization.data(withJSONObject: body))
    }
    
    func importCSV(url: URL) async throws -> Bool {
        return try await NetworkManager.shared.uploadFile(endpoint: "/Expense/rest/expense/import", fileURL: url)
    }
    
    func deleteAllExpenses() async throws {
        // No direct bulk delete endpoint in spec, iterating might be slow if many items.
        // Assuming we just iterate for now or if there is a clear endpoint we missed, we'd use it.
        // SyncWorker didn't show unique bulk delete either.
        let expenses = try await fetchExpenses()
        for expense in expenses {
            try await deleteExpense(expense)
        }
    }
    
    func getMonthlyStats(year: String) async -> [Double]? {
        if let response = try? await NetworkManager.shared.performRequest(endpoint: "/Expense/rest/expense/getMonthlyAmountOfYear", method: "POST", body: JSONEncoder().encode(["year": year]), responseType: [Double].self) {
            return response
        }
        return nil
    }
}
