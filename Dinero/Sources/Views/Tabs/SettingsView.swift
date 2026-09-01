import SwiftUI

struct SettingsView: View {
    @State private var currency = "USD"
    @State private var notificationsEnabled = true
    @State private var faceIDEnabled = true
    @State private var iCloudSyncEnabled = true
    @State private var showAutomateFlow = false

    var body: some View {
        Form {
            Section {
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
                        Text("john.doe@icloud.com")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Automation") {
                Button {
                    showAutomateFlow = true
                } label: {
                    Label("Automate", systemImage: "bolt.fill")
                }
            }

            Section("Preferences") {
                LabeledContent("Currency") {
                    Text(currency)
                        .foregroundStyle(.secondary)
                }
                Toggle("Notifications", isOn: $notificationsEnabled)
                LabeledContent("Budget Period") {
                    Text("Monthly")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Security") {
                Toggle("Face ID", isOn: $faceIDEnabled)
                Toggle("iCloud Sync", isOn: $iCloudSyncEnabled)
            }

            Section("Data") {
                NavigationLink("Export Data") {}
                NavigationLink("Manage Categories") {}
            }

            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                NavigationLink("Rate on App Store") {}
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showAutomateFlow) {
            AutomateFlowView()
        }
    }
}
