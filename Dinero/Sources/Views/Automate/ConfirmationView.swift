import SwiftUI

// MARK: - 4.9a Confirmation

struct ConfirmationView: View {
    let trigger: TriggerType
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(trigger.icon)
                .font(.system(size: 40))
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(
                        colors: trigger.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: trigger.gradientColors[0].opacity(0.25), radius: 15, y: 10)
                .padding(.bottom, 22)

            Text("Automation Turned On")
                .font(.system(size: 21, weight: .bold))

            Text("Every time \(trigger.title.lowercased()) occurs, your expense will be logged and categorized automatically.")
                .font(.system(size: 14.5))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 8)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                LabeledContent("Runs", value: "Automatically")
                Divider()
                LabeledContent("Actions", value: "5 steps")
                Divider()
                HStack {
                    Text("Notifications")
                    Spacer()
                    Text("On")
                        .foregroundStyle(.green)
                }
            }
            .font(.system(size: 13))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .glassCard()
            .padding(.top, 28)

            Spacer()

            Button(action: onFinish) {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [Color.accentBlue, Color.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 32)
        .navigationTitle("Confirmation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 4.9b Live Preview

struct LivePreviewView: View {
    let trigger: TriggerType
    var onRestart: () -> Void
    var onDone: () -> Void

    @State private var stage = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Simulate the automation running")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 16)

                VStack(spacing: 16) {
                    Text("Simulated lock screen")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)

                    if stage == 0 {
                        Button {
                            runDemo()
                        } label: {
                            Text("\u{1F4B3} Simulate Apple Pay Tap")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green, Color.green],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }

                    if stage >= 1 {
                        notificationBanner
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if stage == 2 {
                        Button("Run Again") {
                            stage = 0
                        }
                        .font(.system(size: 14, weight: .medium))
                    }
                }
                .glassCard(padding: 20)

                Button(action: onRestart) {
                    Text("Build Another Automation")
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color(.separator), lineWidth: 1.5)
                        )
                }
                .padding(.top, 20)

                Button(action: onDone) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [Color.accentBlue, Color.accentPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Try It")
    }

    private var notificationBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Text("\u{26A1}\u{FE0F}")
                    .font(.system(size: 14))
                    .frame(width: 28, height: 28)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color(hex: 0xAF52DE)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text("Shortcuts")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text("now")
                    .font(.system(size: 11))
                    .foregroundStyle(.gray)
            }

            Text(stage == 1 ? "Detecting payment\u{2026}" : "Logged $24.50 at Blue Bottle Coffee")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)

            if stage == 2 {
                Text("Categorized as Food & Drink")
                    .font(.system(size: 12.5))
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemFill).opacity(0.92))
        )
        .colorScheme(.dark)
        .frame(maxWidth: 320)
    }

    private func runDemo() {
        withAnimation(.easeInOut(duration: 0.3)) {
            stage = 1
        }
        Task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeInOut(duration: 0.3)) {
                stage = 2
            }
        }
    }
}
