import SwiftUI

enum Category: String, CaseIterable, Identifiable, Codable, Sendable {
    case food
    case transport
    case shopping
    case entertainment
    case health
    case bills
    case travel
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .food: "Food & Drink"
        case .transport: "Transport"
        case .shopping: "Shopping"
        case .entertainment: "Entertainment"
        case .health: "Health"
        case .bills: "Bills"
        case .travel: "Travel"
        case .other: "Other"
        }
    }

    var shortLabel: String {
        switch self {
        case .food: "Food"
        case .transport: "Transport"
        case .shopping: "Shopping"
        case .entertainment: "Fun"
        case .health: "Health"
        case .bills: "Bills"
        case .travel: "Travel"
        case .other: "Other"
        }
    }

    var icon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car.fill"
        case .shopping: "bag.fill"
        case .entertainment: "film.fill"
        case .health: "heart.fill"
        case .bills: "doc.text.fill"
        case .travel: "airplane"
        case .other: "shippingbox.fill"
        }
    }

    var emoji: String {
        switch self {
        case .food: "\u{1F37D}"
        case .transport: "\u{1F697}"
        case .shopping: "\u{1F6CD}"
        case .entertainment: "\u{1F3AC}"
        case .health: "\u{1F48A}"
        case .bills: "\u{1F4C4}"
        case .travel: "\u{2708}\u{FE0F}"
        case .other: "\u{1F4E6}"
        }
    }

    var color: Color {
        switch self {
        case .food: Color(hex: 0xFF6B35)
        case .transport: Color(hex: 0x4ECDC4)
        case .shopping: Color(hex: 0xA855F7)
        case .entertainment: Color(hex: 0xF43F5E)
        case .health: Color(hex: 0x10B981)
        case .bills: Color(hex: 0x3B82F6)
        case .travel: Color(hex: 0xF59E0B)
        case .other: Color(hex: 0x6B7280)
        }
    }
}
