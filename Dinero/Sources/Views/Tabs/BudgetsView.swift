import SwiftUI
import Charts

struct BudgetsView: View {
    @Environment(ExpenseStore.self) private var store

    private var budgetItems: [(budget: Budget, spent: Decimal, category: Category)] {
        store.budgets.map { budget in
            let spent = store.spent(for: budget.category)
            return (budget: budget, spent: spent, category: budget.category)
        }
    }

    private var totalSpent: Double {
        budgetItems.reduce(0) { $0 + NSDecimalNumber(decimal: $1.spent).doubleValue }
    }

    private var totalLimit: Double {
        budgetItems.reduce(0) { $0 + NSDecimalNumber(decimal: $1.budget.monthlyLimit).doubleValue }
    }

    private var percentUsed: Int {
        Int(totalSpent / max(totalLimit, 1) * 100)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                donutChart
                budgetList
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .navigationTitle("Budgets")
    }

    // MARK: - Donut Chart

    private var donutChart: some View {
        VStack(spacing: 16) {
            Chart(budgetItems.filter { $0.spent > 0 }, id: \.category) { item in
                SectorMark(
                    angle: .value("Spent", NSDecimalNumber(decimal: item.spent).doubleValue),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .foregroundStyle(item.category.color)
                .cornerRadius(4)
            }
            .chartBackground { chartProxy in
                GeometryReader { geo in
                    if let plotFrame = chartProxy.plotFrame {
                        VStack(spacing: 2) {
                            Text("\(percentUsed)%")
                                .font(.system(size: 28, weight: .bold))
                            Text("of budget")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .position(x: geo[plotFrame].midX, y: geo[plotFrame].midY)
                    }
                }
            }
            .chartLegend(position: .bottom, spacing: 12)
            .frame(height: 220)
        }
        .glassCard(padding: 24)
    }

    // MARK: - Budget List

    private var budgetList: some View {
        ForEach(budgetItems, id: \.category) { item in
            BudgetCard(
                category: item.category,
                spent: item.spent,
                limit: item.budget.monthlyLimit
            )
        }
    }
}

// MARK: - Budget Card

struct BudgetCard: View {
    let category: Category
    let spent: Decimal
    let limit: Decimal

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return NSDecimalNumber(decimal: spent).doubleValue
            / NSDecimalNumber(decimal: limit).doubleValue
    }

    private var remaining: Decimal {
        limit - spent
    }

    private var isOver: Bool {
        progress > 0.9
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                HStack(spacing: 10) {
                    CategoryChip(category: category, size: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.label)
                            .font(.system(size: 15, weight: .medium))
                        Text("\(AmountFormatter.format(spent)) of \(AmountFormatter.format(limit))")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text("\(AmountFormatter.format(remaining)) left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isOver ? .red : .green)
            }

            Gauge(value: min(progress, 1.0)) { }
                .gaugeStyle(.linearCapacity)
                .tint(progress > 0.9 ? .red : progress > 0.7 ? .orange : category.color)
        }
        .glassCard(padding: 18)
    }
}
