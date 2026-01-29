import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String?  // Assuming backend might send an ID, but it's not strictly required by the prompt
    let username: String
    let email: String
    let name: String
    let surname: String

    // Computed property for initials
    var initials: String {
        let firstInitial = name.first.map { String($0) } ?? ""
        let lastInitial = surname.first.map { String($0) } ?? ""
        return (firstInitial + lastInitial).uppercased()
    }

    // Helper for full name
    var fullName: String {
        return "\(name) \(surname)"
    }
}
