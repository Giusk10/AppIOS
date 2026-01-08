import SwiftUI

@main
struct AppIOSApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .preferredColorScheme(.light) // <--- AGGIUNGI QUESTO
            } else {
                AuthView()
            }
        }
    }
}
