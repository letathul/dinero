import Foundation

enum EntrySource: String, Codable, Sendable {
    case manual
    case applePay
    case automation
}

struct Transaction: Identifiable, Codable, Sendable {
    let id: UUID
    var merchantName: String
    var amount: Decimal
    var category: Category
    var date: Date
    var note: String?
    var source: EntrySource

    init(
        id: UUID = UUID(),
        merchantName: String,
        amount: Decimal,
        category: Category,
        date: Date = Date(),
        note: String? = nil,
        source: EntrySource = .manual
    ) {
        self.id = id
        self.merchantName = merchantName
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.source = source
    }
}
