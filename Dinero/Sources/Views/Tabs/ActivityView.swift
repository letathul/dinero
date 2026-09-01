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
        List {
            filterPills
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            ForEach(groupedFiltered, id: \.label) { group in
                Section(group.label) {
                    ForEach(group.transactions) { txn in
                        HStack(spacing: 12) {
                            CategoryChip(category: txn.category)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(txn.merchantName)
                                    .font(.system(size: 15, weight: .medium))
                                Text("\(txn.category.label) \u{00B7} \(timeString(txn.date))")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\u{2212}\(AmountFormatter.format(txn.amount))")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Activity")
        .searchable(text: $searchText, prompt: "Search transactions")
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
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
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
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    isSelected
                        ? AnyShapeStyle(LinearGradient(
                            colors: [Color.accentBlue, Color.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        : AnyShapeStyle(Color(.systemFill))
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filter by \(label)")
    }
}
