import SwiftUI

extension Color {
    // Primary Brand Colors - Modern Gradient Base
    static let spendyPrimary = Color(hex: "6366F1") // Indigo 500
    static let spendyPrimaryDark = Color(hex: "4F46E5") // Indigo 600
    static let spendyAccent = Color(hex: "8B5CF6") // Violet 500
    
    // Background Colors - Subtle depth
    static let spendyBackground = Color(hex: "F1F5F9") // Slate 100
    static let spendyBackgroundDark = Color(hex: "E2E8F0") // Slate 200
    
    // Surface Colors
    static let spendySurface = Color.white
    static let spendySurfaceElevated = Color(hex: "FAFBFC")
    
    // Text Colors
    static let spendyText = Color(hex: "0F172A") // Slate 900
    static let spendySecondaryText = Color(hex: "64748B") // Slate 500
    static let spendyTertiaryText = Color(hex: "94A3B8") // Slate 400
    
    // Semantic Colors - Vibrant
    static let spendyRed = Color(hex: "EF4444")
    static let spendyGreen = Color(hex: "10B981") // Emerald 500
    static let spendyBlue = Color(hex: "3B82F6")
    static let spendyOrange = Color(hex: "F59E0B") // Amber 500
    static let spendyPink = Color(hex: "EC4899")
    static let spendyCyan = Color(hex: "06B6D4")
    
    // Gradient Definitions
    static var spendyGradient: LinearGradient {
        LinearGradient(
            colors: [spendyPrimary, spendyAccent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var spendyGradientSubtle: LinearGradient {
        LinearGradient(
            colors: [spendyPrimary.opacity(0.1), spendyAccent.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var spendyMeshGradient: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: [
                .spendyPrimary.opacity(0.3), .spendyAccent.opacity(0.2), .spendyCyan.opacity(0.1),
                .spendyAccent.opacity(0.2), .spendyPrimary.opacity(0.15), .spendyPink.opacity(0.1),
                .spendyCyan.opacity(0.1), .spendyPrimary.opacity(0.2), .spendyAccent.opacity(0.3)
            ]
        )
    }
    
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
