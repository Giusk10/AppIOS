import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    
    var body: some View {
        NavigationView {
             ScrollView {
                 VStack(spacing: 24) {
                     if viewModel.isLoading {
                         ProgressView()
                             .padding()
                     } else if let error = viewModel.errorMessage {
                         Text(error)
                             .foregroundColor(.red)
                             .padding()
                     } else {
                         // 1. Top Cards
                         ScrollView(.horizontal, showsIndicators: false) {
                             HStack(spacing: 16) {
                                 SummaryCard(title: "USCITE TOTALI", value: viewModel.totalBalance, subtitle: "\(viewModel.totalTransactions) movimenti", color: .red)
                                 SummaryCard(title: "SPESA MEDIA", value: viewModel.averageExpense, subtitle: "Media per transazione", color: .blue)
                                 SummaryCard(title: "USCITA MAGGIORE", value: viewModel.highestExpense, subtitle: "Max singolo importo", color: .orange)
                             }
                             .padding(.horizontal)
                         }
                         
                         // 2. Chart Section
                         VStack(alignment: .leading, spacing: 16) {
                             Text("Andamento mensile")
                                 .font(.headline)
                                 .padding(.horizontal)
                             
                             if viewModel.monthlyData.isEmpty {
                                 Text("Nessun dato disponibile")
                                     .font(.caption)
                                     .foregroundColor(.secondary)
                                     .padding(.horizontal)
                             } else {
                                 Chart(viewModel.monthlyData) { item in
                                     LineMark(
                                         x: .value("Mese", item.month),
                                         y: .value("Importo", item.amount)
                                     )
                                     .interpolationMethod(.catmullRom)
                                     .foregroundStyle(Color.blue.gradient)
                                     
                                     AreaMark(
                                         x: .value("Mese", item.month),
                                         y: .value("Importo", item.amount)
                                     )
                                     .interpolationMethod(.catmullRom)
                                     .foregroundStyle(
                                         LinearGradient(
                                             colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                                             startPoint: .top,
                                             endPoint: .bottom
                                         )
                                     )
                                 }
                                 .frame(height: 250)
                                 .padding(.horizontal)
                             }
                         }
                         .padding(.vertical)
                         .background(Color(UIColor.secondarySystemGroupedBackground))
                         .cornerRadius(12)
                         .padding(.horizontal)
                         
                         // 3. Categories Section
                         VStack(alignment: .leading, spacing: 16) {
                             Text("Categorie più rilevanti")
                                 .font(.headline)
                                 .padding(.horizontal)
                             
                             ForEach(viewModel.topCategories) { category in
                                 HStack {
                                     VStack(alignment: .leading) {
                                         Text(category.name)
                                             .font(.subheadline)
                                             .bold()
                                         Text("\(category.count) movimenti")
                                             .font(.caption)
                                             .foregroundColor(.secondary)
                                     }
                                     Spacer()
                                     Text(category.amount, format: .currency(code: "EUR"))
                                         .font(.subheadline)
                                         .bold()
                                 }
                                 .padding(.horizontal)
                                 Divider()
                                     .padding(.leading)
                             }
                         }
                         .padding(.vertical)
                         .background(Color(UIColor.secondarySystemGroupedBackground))
                         .cornerRadius(12)
                         .padding(.horizontal)
                     }
                 }
                 .padding(.vertical)
             }
             .background(Color(UIColor.systemGroupedBackground))
             .navigationTitle("Analitica")
             .onAppear {
                 viewModel.loadData()
             }
             .refreshable {
                 viewModel.loadData()
             }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: Double
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value, format: .currency(code: "EUR"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 160, height: 110, alignment: .topLeading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            Rectangle()
                .frame(height: 4)
                .foregroundColor(color),
            alignment: .top
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
