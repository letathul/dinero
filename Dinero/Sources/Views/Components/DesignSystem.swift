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

    static let bgPrimary = Color(hex: 0xF2F2F7)
    static let bgSecondary = Color(hex: 0xE8E8ED)
    static let labelPrimary = Color(hex: 0x1C1C1E)
    static let labelSecondary = Color(hex: 0x8E8E93)
    static let labelTertiary = Color(hex: 0xC7C7CC)
    static let accentBlue = Color(hex: 0x007AFF)
    static let accentPurple = Color(hex: 0x5856D6)
    static let success = Color(hex: 0x34C759)
    static let successAlt = Color(hex: 0x30D158)
    static let warning = Color(hex: 0xFF9500)
    static let danger = Color(hex: 0xFF3B30)
    static let glassFill = Color.white.opacity(0.55)
    static let glassBorder = Color.white.opacity(0.5)
}

// MARK: - Glass Card

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat?

    init(padding: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding ?? 0)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: String?
    var onAction: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.labelPrimary)
            Spacer()
            if let action {
                Button(action) {
                    onAction?()
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.accentBlue)
            }
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

// MARK: - Progress Bar

struct BudgetProgressBar: View {
    let progress: Double
    let color: Color

    private var barColor: Color {
        if progress > 0.9 { return Color.danger }
        if progress > 0.7 { return Color.warning }
        return color
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.06))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: progress > 0.9
                                ? [Color.warning, Color.danger]
                                : [color.opacity(0.6), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * min(CGFloat(progress), 1.0))
                    .animation(.easeOut(duration: 0.8), value: progress)
            }
        }
        .frame(height: 6)
        .clipShape(Capsule())
    }
}

// MARK: - Floating Tab Bar

enum TabItem: String, CaseIterable {
    case summary
    case activity
    case add
    case budgets
    case settings

    var label: String {
        switch self {
        case .summary: "Summary"
        case .activity: "Activity"
        case .add: ""
        case .budgets: "Budgets"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .summary: "house.fill"
        case .activity: "list.bullet"
        case .add: "plus"
        case .budgets: "chart.bar.fill"
        case .settings: "gearshape.fill"
        }
    }
}

struct FloatingTabBar: View {
    @Binding var selection: TabItem
    var onAddTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                if tab == .add {
                    Button(action: onAddTap) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 40)
                            .background(
                                LinearGradient(
                                    colors: [Color.accentBlue, Color.accentPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .accessibilityLabel("Add expense")
                } else {
                    Button {
                        selection = tab
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20))
                                .symbolRenderingMode(.monochrome)
                            Text(tab.label)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(selection == tab ? Color.accentBlue : Color.labelSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    }
                    .accessibilityLabel(tab.label)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - Screen Header

struct ScreenHeader: View {
    let title: String
    var subtitle: String?
    var trailing: AnyView?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .tracking(-0.5)
                    .foregroundStyle(Color.labelPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.labelSecondary)
                }
            }
            Spacer()
            if let trailing {
                trailing
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}
