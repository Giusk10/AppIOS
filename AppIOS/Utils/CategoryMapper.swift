import SwiftUI

struct CategoryMapper {

    static func color(for category: String?) -> Color {
        guard let category = category else { return .spendyPrimary }

        switch category {
        case "Ristorazione e Bar":
            return .spendyOrange
        case "Supermercati e Alimentari":
            return .spendyGreen
        case "Carburante e Auto":
            return .spendyBlue
        case "Trasporti":
            return .spendyBlue
        case "Shopping e Abbigliamento":
            return .spendyPink
        case "Abbonamenti e Servizi Digitali":
            return .spendyAccent
        case "Alloggi e Viaggi":
            return .spendyCyan
        case "Pagamenti e Trasferimenti":
            return .spendyRed
        case "Varie":
            return .spendyPrimary
        case "Non classificato":
            return .spendyPrimary
        default:
            return .spendyPrimary
        }
    }

    static func icon(for category: String?) -> String {
        guard let category = category else { return "questionmark.circle.fill" }

        switch category {
        case "Ristorazione e Bar":
            return "fork.knife"
        case "Supermercati e Alimentari":
            return "basket.fill"
        case "Carburante e Auto":
            return "fuelpump.fill"
        case "Trasporti":
            return "tram.fill"
        case "Shopping e Abbigliamento":
            return "bag.fill"
        case "Abbonamenti e Servizi Digitali":
            return "play.tv.fill"
        case "Alloggi e Viaggi":
            return "airplane"
        case "Pagamenti e Trasferimenti":
            return "arrow.left.arrow.right"
        case "Varie":
            return "tag.fill"
        case "Non classificato":
            return "questionmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }

    // Helper method if needed to normalize or clean category strings
    // But user requested strict mapping, so we trust the input matches the list.
}
