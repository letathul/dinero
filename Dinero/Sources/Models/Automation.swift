import SwiftUI

enum TriggerType: String, CaseIterable, Identifiable, Sendable {
    case applePayTransaction
    case timeOfDay
    case arriveAtLocation
    case actionButton
    case siriPhrase
    case nfcTag

    var id: String { rawValue }

    var title: String {
        switch self {
        case .applePayTransaction: "Apple Pay Transaction"
        case .timeOfDay: "Time of Day"
        case .arriveAtLocation: "Arrive at Location"
        case .actionButton: "Action Button"
        case .siriPhrase: "Siri Phrase"
        case .nfcTag: "NFC Tag"
        }
    }

    var subtitle: String {
        switch self {
        case .applePayTransaction: "Runs after every card payment"
        case .timeOfDay: "Runs on a schedule, e.g. every evening"
        case .arriveAtLocation: "Runs when you reach a saved place"
        case .actionButton: "Runs when you press the side button"
        case .siriPhrase: "\"Hey Siri, log an expense\""
        case .nfcTag: "Runs when you tap a tag"
        }
    }

    var icon: String {
        switch self {
        case .applePayTransaction: "\u{1F4B3}"
        case .timeOfDay: "\u{1F550}"
        case .arriveAtLocation: "\u{1F4CD}"
        case .actionButton: "\u{26A1}\u{FE0F}"
        case .siriPhrase: "\u{1F399}"
        case .nfcTag: "\u{1F4F6}"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .applePayTransaction: [Color(hex: 0x34C759), Color(hex: 0x30D158)]
        case .timeOfDay: [Color(hex: 0xFF9500), Color(hex: 0xFF6B00)]
        case .arriveAtLocation: [Color(hex: 0xFF3B30), Color(hex: 0xFF2D55)]
        case .actionButton: [Color(hex: 0x5856D6), Color(hex: 0xAF52DE)]
        case .siriPhrase: [Color(hex: 0x007AFF), Color(hex: 0x5AC8FA)]
        case .nfcTag: [Color(hex: 0x8E8E93), Color(hex: 0x636366)]
        }
    }

    var isRecommended: Bool {
        self == .applePayTransaction
    }
}

struct ActionStep: Identifiable, Sendable {
    let id: Int
    let app: String
    let title: String
    let detail: String
    let icon: String
    let color: Color
    let isAI: Bool
    let isConditional: Bool

    init(id: Int, app: String, title: String, detail: String, icon: String, color: Color, isAI: Bool = false, isConditional: Bool = false) {
        self.id = id
        self.app = app
        self.title = title
        self.detail = detail
        self.icon = icon
        self.color = color
        self.isAI = isAI
        self.isConditional = isConditional
    }

    static let defaultSteps: [ActionStep] = [
        ActionStep(id: 1, app: "Wallet", title: "Get Latest Transaction", detail: "Amount, Merchant, Date", icon: "\u{1F4B3}", color: Color(hex: 0x34C759)),
        ActionStep(id: 2, app: "Expense Tracker", title: "Guess Category", detail: "Uses Apple Intelligence to match merchant", icon: "\u{1F9E0}", color: Color(hex: 0xAF52DE), isAI: true),
        ActionStep(id: 3, app: "Scripting", title: "If Confidence Is Low", detail: "Ask to confirm category", icon: "\u{1F500}", color: Color(hex: 0xFF9500), isConditional: true),
        ActionStep(id: 4, app: "Expense Tracker", title: "Add Expense", detail: "Save with amount, category, merchant", icon: "\u{2795}", color: Color(hex: 0x007AFF)),
        ActionStep(id: 5, app: "Notifications", title: "Send Quiet Notification", detail: "\"Logged $24.50 at Blue Bottle Coffee\"", icon: "\u{1F514}", color: Color(hex: 0xFF2D55)),
    ]
}

struct Automation: Identifiable, Sendable {
    let id: UUID
    var trigger: TriggerType
    var askBeforeRunning: Bool
    var notifyWhenRun: Bool
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        trigger: TriggerType = .applePayTransaction,
        askBeforeRunning: Bool = false,
        notifyWhenRun: Bool = true,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.trigger = trigger
        self.askBeforeRunning = askBeforeRunning
        self.notifyWhenRun = notifyWhenRun
        self.isEnabled = isEnabled
    }
}
