import SwiftUI

struct ContentView: View {
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            switch authManager.authState {
            case .unauthenticated:
                AuthView()
            case .authenticated:
                MainTabView()
            case .locked:
                LockView()
            case .pinSetup:
                PinSetupView()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: authManager.authState)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            NavigationView {
                UploadView()
            }
            .tabItem {
                Label("Upload", systemImage: "arrow.up.doc.fill")
            }
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie.fill")
                }
        }
        .tint(.spendyPrimary)
    }
}
