import Foundation

struct Expense: Identifiable, Codable {
    var id: String
    var type: String
    var product: String
    var startedDate: String?
    var completedDate: String?
    var userDescription: String
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case product
        case startedDate
        case completedDate
        case userDescription = "description"
        case amount
        case fee
        case currency
        case state
        case category
    }
}

// DTO helper for API if needed, but Expense can now be used directly if it matches JSON.
// The previous DTO matching suggests backend might use "description" vs "userDescription".
// Added CodingKeys to handle that.

