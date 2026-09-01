import SwiftUI

struct ActivityView: View {
    @Environment(ExpenseStore.self) private var store
    @State private var searchText = ""
    @State private var selectedFilter: Category?

    private var filteredTransactions: [Transaction] {
        var result = store.transactions

        if let filter = selectedFilter {
            result = result.filter { $0.category == filter }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.merchantName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    private var groupedFiltered: [(label: String, transactions: [Transaction])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let grouped = Dictionary(grouping: filteredTransactions) { txn -> String in
            let txnDay = calendar.startOfDay(for: txn.date)
            if txnDay == today {
                return "Today"
            } else if txnDay == yesterday {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                return formatter.string(from: txn.date)
            }
        }

        return grouped
            .sorted { g1, g2 in
                let d1 = g1.value.first?.date ?? .distantPast
                let d2 = g2.value.first?.date ?? .distantPast
                return d1 > d2
            }
            .map { (label: $0.key, transactions: $0.value.sorted { $0.date > $1.date }) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScreenHeader(title: "Activity")

                searchField
                    .padding(.bottom, 16)

                filterPills
                    .padding(.bottom, 16)

                ForEach(groupedFiltered, id: \.label) { group in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(group.label.uppercased())
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.labelSecondary)
                            .tracking(0.3)
                            .padding(.vertical, 6)

                        GlassCard {
                            VStack(spacing: 0) {
                                ForEach(Array(group.transactions.enumerated()), id: \.element.id) { index, txn in
                                    HStack(spacing: 12) {
                                        CategoryChip(category: txn.category)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(txn.merchantName)
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundStyle(Color.labelPrimary)
                                            Text("\(txn.category.label) \u{00B7} \(timeString(txn.date))")
                                                .font(.system(size: 12))
                                                .foregroundStyle(Color.labelSecondary)
                                        }

                                        Spacer()

                                        Text("\u{2212}\(AmountFormatter.format(txn.amount))")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(Color.labelPrimary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .overlay(alignment: .bottom) {
                                        if index < group.transactions.count - 1 {
                                            Divider()
                                                .padding(.leading, 68)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(Color.labelSecondary)
            TextField("Search transactions", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Color.labelPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(hex: 0x8E8E93).opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Filter Pills

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(label: "All", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                ForEach(Category.allCases) { cat in
                    FilterPill(
                        label: "\(cat.emoji) \(cat.shortLabel)",
                        isSelected: selectedFilter == cat
                    ) {
                        selectedFilter = cat
                    }
                }
            }
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? .white : Color(hex: 0x3C3C43))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    isSelected
                        ? AnyShapeStyle(LinearGradient(
                            colors: [Color.accentBlue, Color.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        : AnyShapeStyle(Color(hex: 0x8E8E93).opacity(0.12))
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filter by \(label)")
    }
}
