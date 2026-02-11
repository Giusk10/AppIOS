import Foundation

extension Date {
    // Cache dei formatter per performance
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()

    private static let currentYearFullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, HH:mm"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()

    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()

    func formattedDescription(withTime: Bool = false) -> String {
        let calendar = Calendar.current
        let timeString = Date.timeFormatter.string(from: self)

        if calendar.isDateInToday(self) {
            return "Oggi, \(timeString)"
        } else if calendar.isDateInYesterday(self) {
            return "Ieri, \(timeString)"
        } else {
            if withTime {
                // Se è l'anno corrente, nascondiamo l'anno
                if calendar.component(.year, from: self) == calendar.component(.year, from: Date())
                {
                    return Date.currentYearFullDateFormatter.string(from: self)
                } else {
                    return Date.fullDateFormatter.string(from: self)
                }
            } else {
                return Date.shortDateFormatter.string(from: self)
            }
        }
    }
}
