import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .summary
    @State private var showAddExpense = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Summary", systemImage: "house.fill", value: .summary) {
                NavigationStack {
                    SummaryView(selectedTab: $selectedTab)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button { showAddExpense = true } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                }
            }

            Tab("Activity", systemImage: "list.bullet", value: .activity) {
                NavigationStack {
                    ActivityView()
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button { showAddExpense = true } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                }
            }

            Tab("Budgets", systemImage: "chart.pie.fill", value: .budgets) {
                NavigationStack {
                    BudgetsView()
                }
            }

            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView {
                showAddExpense = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(ExpenseStore())
}
