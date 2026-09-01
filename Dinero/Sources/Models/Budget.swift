import Foundation

enum BudgetPeriod: String, Codable, Sendable {
    case monthly
    case weekly
}

struct Budget: Identifiable, Codable, Sendable {
    let id: UUID
    var category: Category
    var monthlyLimit: Decimal
    var period: BudgetPeriod

    init(
        id: UUID = UUID(),
        category: Category,
        monthlyLimit: Decimal,
        period: BudgetPeriod = .monthly
    ) {
        self.id = id
        self.category = category
        self.monthlyLimit = monthlyLimit
        self.period = period
    }
}
