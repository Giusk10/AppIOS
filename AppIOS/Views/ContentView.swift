import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }
            
            NavigationView {
                 UploadView()
            }
            .tabItem {
                Label("Upload", systemImage: "arrow.up.doc")
            }
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
        }
    }
}
