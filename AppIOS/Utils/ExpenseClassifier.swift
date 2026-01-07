import Foundation

struct ExpenseClassifier {

    private static let categoryKeywords: [String: [String]] = [
        "Abbonamenti e Servizi Digitali": [
            "Disney+", "Netflix", "Google One", "Amazon", "g2a.com"
        ],
        "Supermercati e Alimentari": [
            "Carrefour", "Lidl", "Sole 365", "Green Garden", "Pantry", "Market"
        ],
        "Trasporti": [
            "Uber", "FREE NOW", "Trenitalia", "Taxi", "Flight", "Airport"
        ],
        "Ristorazione e Bar": [
            "McDonald's", "Burger King", "KFC", "Il Sauro Ristorante", "S. Paolo Ristorazione",
            "Vino E Biga", "Dorys Caffe", "Bar Big", "Cannavina Bar", "Noemy Cafe", "Big Bang Sandwich",
            "Young Pizza", "Gruppo la Piadineria", "Mastroianni", "Mariano Balato"
        ],
        "Pagamenti e Trasferimenti": [
            "Transfer to Revolut user", "Transfer from Revolut user", "Payment from Riccio Giuseppe",
            "Payment from Porto Vincenzo", "Payment from Iuliani Antonio", "Payment from Mangopay",
            "Balance migration", "SumUp"
        ],
        "Shopping e Abbigliamento": [
            "Zalando", "Douglas", "Vinted", "Proshop"
        ],
        "Alloggi e Viaggi": [
            "Airbnb", "Hotel", "Booking", "Vacation"
        ],
        "Varie": [
            "Samnite", "Samnet", "Margroup Societa", "Colella Group", "Fratelli Della Minerva",
            "Officinastu", "Studiouno Grafhic Foto", "Mne 95016279moneynet"
        ],
        "Carburante e Auto": [
            "Gas", "Fuel", "Petrol"
        ]
    ]

    static func classify(_ description: String?) -> String {
        guard let description = description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Non classificato"
        }

        let descLower = description.lowercased()

        for (category, keywords) in categoryKeywords {
            for keyword in keywords {
                if descLower.contains(keyword.lowercased()) {
                    return category
                }
            }
        }
        return "Non classificato"
    }
}
