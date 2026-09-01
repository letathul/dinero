import SwiftUI

struct SettingsView: View {
    @State private var currency = "USD"
    @State private var notificationsEnabled = true
    @State private var faceIDEnabled = true
    @State private var iCloudSyncEnabled = true
    @State private var showAutomateFlow = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ScreenHeader(title: "Settings")

                profileCard

                SettingsGroup(title: "Automation") {
                    SettingsRow(
                        icon: "\u{26A1}\u{FE0F}",
                        iconBG: Color(hex: 0xFEF3C7),
                        label: "Automate"
                    ) {
                        Button {
                            showAutomateFlow = true
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.labelTertiary)
                        }
                    }
                }

                SettingsGroup(title: "Preferences") {
                    SettingsRow(
                        icon: "\u{1F4B0}",
                        iconBG: Color(hex: 0xFEF3C7),
                        label: "Currency"
                    ) {
                        HStack(spacing: 4) {
                            Text(currency)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.labelSecondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.labelTertiary)
                        }
                    }

                    SettingsRow(
                        icon: "\u{1F514}",
                        iconBG: Color(hex: 0xFEE2E2),
                        label: "Notifications",
                        showDivider: true
                    ) {
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                            .tint(Color.success)
                    }

                    SettingsRow(
                        icon: "\u{1F4C5}",
                        iconBG: Color(hex: 0xDBEAFE),
                        label: "Budget Period",
                        isLast: true
                    ) {
                        HStack(spacing: 4) {
                            Text("Monthly")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.labelSecondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.labelTertiary)
                        }
                    }
                }

                SettingsGroup(title: "Security") {
                    SettingsRow(
                        icon: "\u{1F510}",
                        iconBG: Color(hex: 0xE0E7FF),
                        label: "Face ID"
                    ) {
                        Toggle("", isOn: $faceIDEnabled)
                            .labelsHidden()
                            .tint(Color.success)
                    }

                    SettingsRow(
                        icon: "\u{2601}\u{FE0F}",
                        iconBG: Color(hex: 0xCFFAFE),
                        label: "iCloud Sync",
                        isLast: true
                    ) {
                        Toggle("", isOn: $iCloudSyncEnabled)
                            .labelsHidden()
                            .tint(Color.success)
                    }
                }

                SettingsGroup(title: "Data") {
                    SettingsRow(
                        icon: "\u{1F4CA}",
                        iconBG: Color(hex: 0xD1FAE5),
                        label: "Export Data"
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.labelTertiary)
                    }

                    SettingsRow(
                        icon: "\u{1F3F7}",
                        iconBG: Color(hex: 0xF3E8FF),
                        label: "Manage Categories",
                        isLast: true
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.labelTertiary)
                    }
                }

                SettingsGroup(title: "About") {
                    SettingsRow(
                        icon: "\u{1F48E}",
                        iconBG: Color(hex: 0xEDE9FE),
                        label: "Version"
                    ) {
                        Text("1.0.0")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.labelSecondary)
                    }

                    SettingsRow(
                        icon: "\u{2B50}",
                        iconBG: Color(hex: 0xFEF9C3),
                        label: "Rate on App Store",
                        isLast: true
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.labelTertiary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showAutomateFlow) {
            AutomateFlowView()
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        GlassCard {
            HStack(spacing: 14) {
                Text("JD")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.accentBlue, Color.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("John Doe")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.labelPrimary)
                    Text("john.doe@icloud.com")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.labelSecondary)
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

// MARK: - Settings Group

struct SettingsGroup<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.labelSecondary)
                    .tracking(0.3)
                    .padding(.leading, 4)
            }

            GlassCard {
                VStack(spacing: 0) {
                    content
                }
            }
        }
    }
}

// MARK: - Settings Row

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconBG: Color
    let label: String
    var showDivider: Bool = true
    var isLast: Bool = false
    @ViewBuilder let trailing: Trailing

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 15))
                    .frame(width: 30, height: 30)
                    .background(iconBG)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.labelPrimary)

                Spacer()

                trailing
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)

            if !isLast {
                Divider()
                    .padding(.leading, 58)
            }
        }
    }
}
