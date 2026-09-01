import Foundation
import Observation

@Observable
final class ExpenseStore: @unchecked Sendable {
    var transactions: [Transaction]
    var budgets: [Budget]
    var weeklySpend: [Double] = [320, 280, 410, 195, 365, 290, 180]

    init() {
        self.transactions = Self.sampleTransactions
        self.budgets = Self.sampleBudgets
    }

    // MARK: - Computed

    var totalSpent: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }

    var totalBudget: Decimal {
        budgets.reduce(0) { $0 + $1.monthlyLimit }
    }

    var budgetProgress: Double {
        guard totalBudget > 0 else { return 0 }
        return NSDecimalNumber(decimal: totalSpent).doubleValue
            / NSDecimalNumber(decimal: totalBudget).doubleValue
    }

    func spent(for category: Category) -> Decimal {
        transactions
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    func budget(for category: Category) -> Budget? {
        budgets.first { $0.category == category }
    }

    var topCategories: [(category: Category, total: Decimal)] {
        let grouped = Dictionary(grouping: transactions, by: \.category)
        return grouped.map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { NSDecimalNumber(decimal: $0.total).doubleValue > NSDecimalNumber(decimal: $1.total).doubleValue }
    }

    var transactionsGroupedByDate: [(label: String, transactions: [Transaction])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let grouped = Dictionary(grouping: transactions) { txn -> String in
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
            .sorted { group1, group2 in
                let date1 = group1.value.first?.date ?? .distantPast
                let date2 = group2.value.first?.date ?? .distantPast
                return date1 > date2
            }
            .map { (label: $0.key, transactions: $0.value.sorted { $0.date > $1.date }) }
    }

    // MARK: - Actions

    func addTransaction(merchantName: String, amount: Decimal, category: Category, note: String?) {
        let txn = Transaction(
            merchantName: merchantName,
            amount: amount,
            category: category,
            note: note
        )
        transactions.insert(txn, at: 0)
    }

    func updateBudgetLimit(for category: Category, newLimit: Decimal) {
        if let idx = budgets.firstIndex(where: { $0.category == category }) {
            budgets[idx].monthlyLimit = newLimit
        }
    }

    // MARK: - Sample Data

    private static let calendar = Calendar.current

    private static func date(daysAgo: Int, hour: Int = 10, minute: Int = 0) -> Date {
        let today = calendar.startOfDay(for: Date())
        let day = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
    }

    static let sampleTransactions: [Transaction] = [
        Transaction(merchantName: "Whole Foods Market", amount: 67.43, category: .food, date: date(daysAgo: 0, hour: 10, minute: 24)),
        Transaction(merchantName: "Uber", amount: 24.50, category: .transport, date: date(daysAgo: 0, hour: 8, minute: 15)),
        Transaction(merchantName: "Netflix", amount: 15.99, category: .entertainment, date: date(daysAgo: 1)),
        Transaction(merchantName: "Apple Store", amount: 199.00, category: .shopping, date: date(daysAgo: 2, hour: 15, minute: 42)),
        Transaction(merchantName: "Starbucks", amount: 6.75, category: .food, date: date(daysAgo: 2, hour: 7, minute: 50)),
        Transaction(merchantName: "Electric Bill", amount: 142.30, category: .bills, date: date(daysAgo: 3, hour: 9)),
        Transaction(merchantName: "CVS Pharmacy", amount: 32.15, category: .health, date: date(daysAgo: 4, hour: 17, minute: 30)),
        Transaction(merchantName: "Target", amount: 89.60, category: .shopping, date: date(daysAgo: 4, hour: 14, minute: 10)),
        Transaction(merchantName: "Lyft", amount: 18.90, category: .transport, date: date(daysAgo: 5, hour: 18, minute: 45)),
        Transaction(merchantName: "Chipotle", amount: 14.25, category: .food, date: date(daysAgo: 5, hour: 12, minute: 30)),
        Transaction(merchantName: "Gym Membership", amount: 49.99, category: .health, date: date(daysAgo: 6)),
        Transaction(merchantName: "Delta Airlines", amount: 342.00, category: .travel, date: date(daysAgo: 7, hour: 10)),
        Transaction(merchantName: "Spotify", amount: 10.99, category: .entertainment, date: date(daysAgo: 7)),
        Transaction(merchantName: "Trader Joe's", amount: 54.80, category: .food, date: date(daysAgo: 8, hour: 11, minute: 20)),
        Transaction(merchantName: "Water Bill", amount: 38.50, category: .bills, date: date(daysAgo: 9, hour: 9)),
    ]

    static let sampleBudgets: [Budget] = [
        Budget(category: .food, monthlyLimit: 400),
        Budget(category: .transport, monthlyLimit: 150),
        Budget(category: .shopping, monthlyLimit: 300),
        Budget(category: .entertainment, monthlyLimit: 100),
        Budget(category: .health, monthlyLimit: 200),
        Budget(category: .bills, monthlyLimit: 500),
        Budget(category: .travel, monthlyLimit: 600),
    ]
}
