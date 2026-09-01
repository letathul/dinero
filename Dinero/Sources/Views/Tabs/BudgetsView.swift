import SwiftUI

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

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenHeader(
                    title: "Budgets",
                    subtitle: currentPeriodString
                )

                donutChart
                budgetList
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Donut Chart

    private var donutChart: some View {
        GlassCard(padding: 24) {
            VStack(spacing: 16) {
                ZStack {
                    donutRing
                        .frame(width: 180, height: 180)

                    VStack(spacing: 2) {
                        Text("\(Int(totalSpent / max(totalLimit, 1) * 100))%")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.labelPrimary)
                        Text("of budget")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.labelSecondary)
                    }
                }

                legendChips
            }
        }
    }

    private var donutRing: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = 70
            let lineWidth: CGFloat = 22
            let gap: CGFloat = 0.02

            guard totalSpent > 0 else { return }

            var startAngle = Angle.degrees(-90)

            for item in budgetItems {
                let spent = NSDecimalNumber(decimal: item.spent).doubleValue
                guard spent > 0 else { continue }
                let fraction = spent / totalSpent
                let sweep = Angle.degrees(360 * fraction - (gap * 360))

                let path = Path { p in
                    p.addArc(
                        center: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: startAngle + sweep,
                        clockwise: false
                    )
                }

                context.stroke(
                    path,
                    with: .color(item.category.color),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

                startAngle = startAngle + sweep + Angle.degrees(gap * 360)
            }
        }
    }

    private var legendChips: some View {
        let items = budgetItems.filter { $0.spent > 0 }
            .sorted { NSDecimalNumber(decimal: $0.spent).doubleValue > NSDecimalNumber(decimal: $1.spent).doubleValue }
            .prefix(5)

        return FlowLayout(spacing: 12) {
            ForEach(Array(items), id: \.category) { item in
                HStack(spacing: 4) {
                    Circle()
                        .fill(item.category.color)
                        .frame(width: 8, height: 8)
                    Text(item.category.shortLabel)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: 0x6B7280))
                }
            }
        }
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

    private var currentPeriodString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
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
        GlassCard {
            VStack(spacing: 10) {
                HStack {
                    HStack(spacing: 10) {
                        CategoryChip(category: category, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.label)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.labelPrimary)
                            Text("\(AmountFormatter.format(spent)) of \(AmountFormatter.format(limit))")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.labelSecondary)
                        }
                    }
                    Spacer()
                    Text("\(AmountFormatter.format(remaining)) left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isOver ? Color.danger : Color.success)
                }

                BudgetProgressBar(progress: progress, color: category.color)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, point) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
