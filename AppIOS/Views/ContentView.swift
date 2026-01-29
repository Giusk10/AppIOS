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
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)

            AnalyticsView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "chart.pie.fill" : "chart.pie")
                    Text("Analytics")
                }
                .tag(1)
        }
        .tint(.spendyPrimary)
    }
}
