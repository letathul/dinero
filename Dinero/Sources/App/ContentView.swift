import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .summary
    @State private var showAddExpense = false

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color.bgPrimary, Color.bgSecondary, Color.bgPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            FloatingTabBar(selection: $selectedTab) {
                showAddExpense = true
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView {
                showAddExpense = false
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .summary:
            SummaryView(onNavigate: { tab in
                selectedTab = tab
            })
        case .activity:
            ActivityView()
        case .add:
            Color.clear
        case .budgets:
            BudgetsView()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .environment(ExpenseStore())
}
