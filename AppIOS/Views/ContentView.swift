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
    @State private var selectedTab: TabBarItem = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            Group {
                switch selectedTab {
                case .home:
                    DashboardView()
                case .upload:
                    NavigationView {
                        UploadView()
                    }
                case .analytics:
                    AnalyticsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
