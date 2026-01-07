import Foundation

import SwiftData

@Model
class Expense: Identifiable {
    @Attribute(.unique) var id: String
    var type: String
    var product: String
    var startedDate: String?
    var completedDate: String?
    var userDescription: String // 'description' is a reserved word in Swift objects sometimes, better avoid or override
    var amount: Double
    var fee: Double?
    var currency: String?
    var state: String?
    var category: String?
    
    init(id: String = UUID().uuidString, type: String = "", product: String = "", startedDate: String? = nil, completedDate: String? = nil, description: String = "", amount: Double = 0.0, fee: Double? = nil, currency: String? = nil, state: String? = nil, category: String? = nil) {
        self.id = id
        self.type = type
        self.product = product
        self.startedDate = startedDate
        self.completedDate = completedDate
        self.userDescription = description
        self.amount = amount
        self.fee = fee
        self.currency = currency
        self.state = state
        self.category = category
    }
}

struct AggregatedExpenseMetrics: Codable {
    var totalExpenses: Double
    var averageExpense: Double
    var highestExpense: Double
    var totalTransactions: Int
    var categories: [CategoryMetric]
    
    struct CategoryMetric: Codable {
        var name: String
        var total: Double
        var transactions: Int
    }
}
