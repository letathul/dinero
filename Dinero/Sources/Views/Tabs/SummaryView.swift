import SwiftUI

struct SummaryView: View {
    @Environment(ExpenseStore.self) private var store
    var onNavigate: (TabItem) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenHeader(
                    title: "Summary",
                    subtitle: currentMonthString,
                    trailing: AnyView(avatarView)
                )

                heroCard
                weeklyChart
                topCategoriesCard
                recentTransactionsCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        GlassCard(padding: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Total Spent")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: 0x6B7280))

                Text(AmountFormatter.format(store.totalSpent))
                    .font(.system(size: 42, weight: .bold))
                    .tracking(-1.5)
                    .foregroundStyle(Color.labelPrimary)
                    .padding(.top, 4)

                Text("of \(AmountFormatter.format(store.totalBudget)) budget")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.labelSecondary)
                    .padding(.top, 6)

                BudgetProgressBar(
                    progress: store.budgetProgress,
                    color: Color.success
                )
                .padding(.top, 16)

                HStack {
                    Text("\(Int(store.budgetProgress * 100))% used")
                    Spacer()
                    Text("\(AmountFormatter.format(store.totalBudget - store.totalSpent)) remaining")
                }
                .font(.system(size: 12))
                .foregroundStyle(Color.labelSecondary)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Weekly Bar Chart

    private var weeklyChart: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("This Week")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.labelPrimary)

                HStack(alignment: .bottom, spacing: 8) {
                    let maxVal = store.weeklySpend.max() ?? 1
                    let weekLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                    let todayIndex = 6

                    ForEach(Array(store.weeklySpend.enumerated()), id: \.offset) { index, value in
                        VStack(spacing: 6) {
                            Text("$\(Int(value))")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color.labelSecondary)

                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(
                                    index == todayIndex
                                        ? LinearGradient(colors: [Color.accentBlue, Color.accentPurple], startPoint: .top, endPoint: .bottom)
                                        : LinearGradient(colors: [Color.accentBlue.opacity(0.12), Color.accentBlue.opacity(0.12)], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(height: CGFloat(value / maxVal) * 72)

                            Text(weekLabels[index])
                                .font(.system(size: 11, weight: index == todayIndex ? .semibold : .medium))
                                .foregroundStyle(index == todayIndex ? Color.accentBlue : Color.labelSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 120)
            }
        }
    }

    // MARK: - Top Categories

    private var topCategoriesCard: some View {
        GlassCard(padding: 20) {
            VStack(spacing: 0) {
                SectionHeader(title: "Top Categories", action: "See All") {
                    onNavigate(.budgets)
                }
                .padding(.bottom, 14)

                ForEach(Array(store.topCategories.prefix(4).enumerated()), id: \.element.category) { index, item in
                    HStack(spacing: 12) {
                        CategoryChip(category: item.category, size: 36)

                        Text(item.category.label)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.labelPrimary)

                        Spacer()

                        Text(AmountFormatter.format(item.total))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.labelPrimary)
                    }
                    .padding(.vertical, 10)
                    .overlay(alignment: .top) {
                        if index > 0 {
                            Divider().opacity(0.3)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recent Transactions

    private var recentTransactionsCard: some View {
        GlassCard(padding: 20) {
            VStack(spacing: 0) {
                SectionHeader(title: "Recent", action: "See All") {
                    onNavigate(.activity)
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
        }
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

    private var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
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
                    .foregroundStyle(Color.labelPrimary)
                Text(timeString)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.labelSecondary)
            }

            Spacer()

            Text("\u{2212}\(AmountFormatter.format(transaction.amount))")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.labelPrimary)
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
