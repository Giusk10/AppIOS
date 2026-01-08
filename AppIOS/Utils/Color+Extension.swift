import SwiftUI

extension Color {
    // Primary Brand Color (Indigo/Blurple)
    // Matches the "Accedi" button and "Component" highlights
    static let spendyPrimary = Color(hex: "4F46E5")
    
    // Background Color (Light Gray/Blue)
    // Matches the main page background
    static let spendyBackground = Color(hex: "F8FAFC")
    
    // Secondary Background (White)
    // For cards, inputs, etc.
    static let spendySurface = Color.white
    
    // Text Colors
    static let spendyText = Color(hex: "1E293B") // Slate 800
    static let spendySecondaryText = Color(hex: "64748B") // Slate 500
    
    // Semantic Colors
    static let spendyRed = Color(hex: "EF4444")
    static let spendyGreen = Color(hex: "22C55E")
    static let spendyBlue = Color(hex: "3B82F6")
    static let spendyOrange = Color(hex: "F97316")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
