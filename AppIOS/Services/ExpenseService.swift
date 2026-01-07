import Foundation

import Foundation
import SwiftData

@MainActor
class ExpenseService {
    static let shared = ExpenseService()
    var modelContext: ModelContext?

    private init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func fetchExpenses() throws -> [Expense] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<Expense>(sortBy: [SortDescriptor(\.startedDate, order: .reverse)])
        return try context.fetch(descriptor)
    }
    
    func addExpense(_ expense: Expense) {
        modelContext?.insert(expense)
    }
    
    func deleteExpense(_ expense: Expense) {
        modelContext?.delete(expense)
    }
    
    func importCSV(url: URL) throws {
        // Implementation for CSV parsing will go here
        guard let context = modelContext else { return }
        
        let data = try String(contentsOf: url, encoding: .utf8)
        let rows = data.components(separatedBy: "\n")
        
        // Skip header if exists, assuming first row is header
        for (index, row) in rows.enumerated() {
            if index == 0 { continue } // Skip header
            let columns = row.components(separatedBy: ",") // Basic CSV parsing, might need more robust parser for quoted fields
            if columns.count >= 4 { // Basic validation
                 // Mapping columns to Expense fields (Adjust index based on SpendyApp CSV format)
                 // Assuming format: Date, Description, Amount, Category... (Need to verify)
                 // For now creating a dummy implementation to be refined
                 // Let's assume standard simple CSV
                 
                let description = columns[1]
                if let amount = Double(columns[2]) {
                     let expense = Expense(description: description, amount: amount)
                     context.insert(expense)
                }
            }
        }
    }
    
    // Kept for compatibility but logic is now local filtering
    func fetchExpensesByDate(start: String, end: String) throws -> [Expense] {
        let all = try fetchExpenses()
        // Simple string filtering, should be improved with real Date objects
        return all.filter { ($0.startedDate ?? "") >= start && ($0.startedDate ?? "") <= end }
    }
}

// Minimal AnyCodable wrapper for mixed JSON values
enum AnyCodable: Codable {
    case string(String)
    case double(Double)
    case int(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(Int.self) {
            self = .int(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for AnyCodable"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x): try container.encode(x)
        case .double(let x): try container.encode(x)
        case .int(let x): try container.encode(x)
        }
    }
}
