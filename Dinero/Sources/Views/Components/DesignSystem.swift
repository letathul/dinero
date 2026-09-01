import SwiftUI

// MARK: - Color Extension

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    static let bgPrimary = Color(.systemGroupedBackground)
    static let bgSecondary = Color(.secondarySystemGroupedBackground)
    static let labelPrimary = Color(.label)
    static let labelSecondary = Color(.secondaryLabel)
    static let labelTertiary = Color(.tertiaryLabel)
    static let accentBlue = Color.blue
    static let accentPurple = Color.purple
    static let success = Color.green
    static let successAlt = Color.green
    static let warning = Color.orange
    static let danger = Color.red
}

// MARK: - Glass Card Modifier

extension View {
    func glassCard(padding: CGFloat = 0) -> some View {
        self
            .padding(padding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

// MARK: - Tab

enum AppTab: String, CaseIterable, Hashable {
    case summary
    case activity
    case budgets
    case settings

    var label: String {
        switch self {
        case .summary: "Summary"
        case .activity: "Activity"
        case .budgets: "Budgets"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .summary: "house.fill"
        case .activity: "list.bullet"
        case .budgets: "chart.pie.fill"
        case .settings: "gearshape.fill"
        }
    }
}

// MARK: - Category Icon Chip

struct CategoryChip: View {
    let category: Category
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: category.icon)
            .font(.system(size: size * 0.4, weight: .medium))
            .foregroundStyle(category.color)
            .frame(width: size, height: size)
            .background(category.color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
    }
}

// MARK: - Amount Formatter

struct AmountFormatter {
    static func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}
