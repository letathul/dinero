import SwiftUI
import Charts

struct SummaryView: View {
    @Environment(ExpenseStore.self) private var store
    @Binding var selectedTab: AppTab

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                heroCard
                weeklyChart
                topCategoriesCard
                recentTransactionsCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .navigationTitle("Summary")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                avatarView
            }
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Total Spent")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)

            Text(AmountFormatter.format(store.totalSpent))
                .font(.system(size: 42, weight: .bold))
                .tracking(-1.5)
                .foregroundStyle(.primary)
                .padding(.top, 4)

            Text("of \(AmountFormatter.format(store.totalBudget)) budget")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.top, 6)

            ProgressView(value: min(store.budgetProgress, 1.0))
                .tint(store.budgetProgress > 0.9 ? .red : store.budgetProgress > 0.7 ? .orange : .green)
                .padding(.top, 16)

            HStack {
                Text("\(Int(store.budgetProgress * 100))% used")
                Spacer()
                Text("\(AmountFormatter.format(store.totalBudget - store.totalSpent)) remaining")
            }
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .padding(.top, 8)
        }
        .glassCard(padding: 24)
    }

    // MARK: - Weekly Bar Chart

    private var weeklyChart: some View {
        let weekLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let todayIndex = 6

        return VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.system(size: 15, weight: .semibold))

            Chart {
                ForEach(Array(store.weeklySpend.enumerated()), id: \.offset) { index, value in
                    BarMark(
                        x: .value("Day", weekLabels[index]),
                        y: .value("Spend", value)
                    )
                    .foregroundStyle(index == todayIndex ? Color.accentBlue : Color.accentBlue.opacity(0.15))
                    .cornerRadius(6)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 120)
        }
        .glassCard(padding: 20)
    }

    // MARK: - Top Categories

    private var topCategoriesCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Top Categories")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Button("See All") {
                    selectedTab = .budgets
                }
                .font(.system(size: 13, weight: .medium))
            }
            .padding(.bottom, 14)

            ForEach(Array(store.topCategories.prefix(4).enumerated()), id: \.element.category) { index, item in
                HStack(spacing: 12) {
                    CategoryChip(category: item.category, size: 36)

                    Text(item.category.label)
                        .font(.system(size: 14, weight: .medium))

                    Spacer()

                    Text(AmountFormatter.format(item.total))
                        .font(.system(size: 15, weight: .semibold))
                }
                .padding(.vertical, 10)
                .overlay(alignment: .top) {
                    if index > 0 {
                        Divider().opacity(0.3)
                    }
                }
            }
        }
        .glassCard(padding: 20)
    }

    // MARK: - Recent Transactions

    private var recentTransactionsCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Recent")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Button("See All") {
                    selectedTab = .activity
                }
                .font(.system(size: 13, weight: .medium))
            }
            .padding(.bottom, 14)

            ForEach(Array(store.transactions.prefix(4).enumerated()), id: \.element.id) { index, txn in
                TransactionRow(transaction: txn)
                    .overlay(alignment: .top) {
                        if index > 0 {
                            Divider().opacity(0.3)
                        }
                    }
            }
        }
        .glassCard(padding: 20)
    }

    // MARK: - Helpers

    private var avatarView: some View {
        Text("JD")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(
                LinearGradient(
                    colors: [Color.accentBlue, Color.accentPurple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Circle())
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            CategoryChip(category: transaction.category)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchantName)
                    .font(.system(size: 15, weight: .medium))
                Text(timeString)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\u{2212}\(AmountFormatter.format(transaction.amount))")
                .font(.system(size: 15, weight: .semibold))
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: transaction.date)
    }
}
