import SwiftUI

struct CategoryMapper {

    static func color(for category: String?, description: String? = nil) -> Color {
        let cat = resolveCategory(category: category, description: description)

        switch cat.lowercased() {
        case "food", "cibo", "alimentari", "ristorante", "ristoranti", "bar", "pizzeria", "pub":
            return .spendyOrange
        case "groceries", "spesa", "supermercato":
            return .spendyGreen
        case "transport", "trasporti", "taxi", "uber", "benzina", "carburante", "treno", "bus",
            "metro", "parcheggio":
            return .spendyBlue
        case "shopping", "abbigliamento", "vestiti", "moda", "accessori":
            return .spendyPink
        case "entertainment", "intrattenimento", "cinema", "teatro", "concerti", "sport",
            "palestra", "hobby", "streaming":
            return .spendyAccent
        case "bills", "bollette", "utenze", "affitto", "mutuo", "assicurazione", "telefono",
            "internet", "luce", "gas":
            return .spendyRed
        case "health", "salute", "farmacia", "medico", "dentista", "ospedale":
            return .spendyGreen
        case "viaggi", "travel", "hotel", "volo", "vacanza":
            return .spendyCyan
        case "casa", "home", "arredamento", "elettrodomestici":
            return .spendyOrange
        case "tech", "tecnologia", "elettronica", "computer", "smartphone", "software":
            return .spendyBlue
        case "stipendio", "salary", "income", "entrata", "rimborso":
            return .spendyGreen
        default:
            return .spendyPrimary
        }
    }

    static func icon(for category: String?, description: String? = nil) -> String {
        let cat = resolveCategory(category: category, description: description)

        switch cat.lowercased() {
        case "food", "cibo", "ristorante", "ristoranti", "bar", "pizzeria", "pub":
            return "fork.knife"
        case "groceries", "alimentari", "spesa", "supermercato":
            return "basket.fill"
        case "transport", "trasporti", "taxi", "uber", "benzina", "carburante", "parcheggio":
            return "car.fill"
        case "treno", "bus", "metro":
            return "tram.fill"
        case "shopping", "abbigliamento", "vestiti", "moda", "accessori":
            return "bag.fill"
        case "entertainment", "intrattenimento", "cinema", "teatro", "concerti", "streaming":
            return "film.fill"
        case "sport", "palestra":
            return "figure.run"
        case "hobby":
            return "gamecontroller.fill"
        case "bills", "bollette", "utenze":
            return "doc.text.fill"
        case "affitto", "mutuo":
            return "house.fill"
        case "assicurazione":
            return "shield.fill"
        case "telefono", "internet", "luce", "gas":
            return "bolt.fill"
        case "health", "salute", "farmacia":
            return "cross.case.fill"
        case "medico", "dentista", "ospedale":
            return "heart.fill"
        case "viaggi", "travel", "hotel", "volo", "vacanza":
            return "airplane"
        case "casa", "home", "arredamento", "elettrodomestici":
            return "sofa.fill"
        case "tech", "tecnologia", "elettronica", "computer", "smartphone", "software":
            return "laptopcomputer"
        case "stipendio", "salary", "income", "entrata", "rimborso":
            return "banknote.fill"
        default:
            return "creditcard.fill"
        }
    }

    private static func resolveCategory(category: String?, description: String?) -> String {
        // If we have a valid category from backend, use it
        if let category = category, !category.isEmpty, category.lowercased() != "altro" {
            return category
        }

        // Otherwise try to infer from description
        guard let description = description?.lowercased() else { return "altro" }

        // Inference Rules
        if description.contains("coffee") || description.contains("caffe")
            || description.contains("starbucks") || description.contains("bar")
        {
            return "bar"
        }
        if description.contains("siren coffee") { return "bar" }
        if description.contains("mcdonalds") || description.contains("burger")
            || description.contains("kfc") || description.contains("pizza")
        {
            return "food"
        }
        if description.contains("ristorante") || description.contains("restaurant")
            || description.contains("sushi")
        {
            return "ristorante"
        }

        if description.contains("market") || description.contains("supermercato")
            || description.contains("coop") || description.contains("conad")
            || description.contains("esselunga") || description.contains("carrefour")
            || description.contains("lidl") || description.contains("eurospin")
            || description.contains("sole 365")
        {
            return "groceries"
        }

        if description.contains("uber") || description.contains("taxi") { return "taxi" }
        if description.contains("benzina") || description.contains("eni")
            || description.contains("q8") || description.contains("esso")
            || description.contains("ip")
        {
            return "benzina"
        }
        if description.contains("treno") || description.contains("trenitalia")
            || description.contains("italo")
        {
            return "treno"
        }

        if description.contains("netflix") || description.contains("spotify")
            || description.contains("prime") || description.contains("disney")
        {
            return "streaming"
        }

        if description.contains("vodafone") || description.contains("tim")
            || description.contains("wind") || description.contains("iliad")
            || description.contains("ho.")
        {
            return "telefono"
        }
        if description.contains("enel") || description.contains("a2a")
            || description.contains("iren") || description.contains("hera")
            || description.contains("luce") || description.contains("gas")
        {
            return "bollette"
        }
        if description.contains("ricarica") { return "telefono" }

        if description.contains("farmacia") { return "farmacia" }

        if description.contains("amazon") { return "shopping" }
        if description.contains("zara") || description.contains("h&m")
            || description.contains("nike") || description.contains("adidas")
        {
            return "abbigliamento"
        }

        if description.contains("apple") || description.contains("mediaworld")
            || description.contains("unieuro") || description.contains("euronics")
            || description.contains("render")
        {
            return "tech"
        }

        return "altro"
    }
}
