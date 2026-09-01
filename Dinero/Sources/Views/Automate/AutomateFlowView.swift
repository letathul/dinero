import SwiftUI

enum AutomateStep: Hashable {
    case triggerPicker
    case editor
    case confirmation
    case preview
}

struct AutomateFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var path = NavigationPath()
    @State private var selectedTrigger: TriggerType = .applePayTransaction

    var body: some View {
        NavigationStack(path: $path) {
            AutomateEntryView(
                onStart: {
                    selectedTrigger = .applePayTransaction
                    path.append(AutomateStep.editor)
                },
                onSelectTrigger: { trigger in
                    selectedTrigger = trigger
                    path.append(AutomateStep.editor)
                },
                onPickOther: {
                    path.append(AutomateStep.triggerPicker)
                }
            )
            .navigationDestination(for: AutomateStep.self) { step in
                switch step {
                case .triggerPicker:
                    TriggerPickerView { trigger in
                        selectedTrigger = trigger
                        path.append(AutomateStep.editor)
                    }
                case .editor:
                    AutomationEditorView(
                        trigger: selectedTrigger,
                        onDone: { path.append(AutomateStep.confirmation) }
                    )
                case .confirmation:
                    ConfirmationView(
                        trigger: selectedTrigger,
                        onFinish: { path.append(AutomateStep.preview) }
                    )
                case .preview:
                    LivePreviewView(
                        trigger: selectedTrigger,
                        onRestart: {
                            path = NavigationPath()
                            path.append(AutomateStep.triggerPicker)
                        },
                        onDone: { dismiss() }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 4.6 Entry Screen

struct AutomateEntryView: View {
    var onStart: () -> Void
    var onSelectTrigger: (TriggerType) -> Void
    var onPickOther: () -> Void

    var body: some View {
        List {
            Section {
                Button(action: onStart) {
                    HStack(spacing: 12) {
                        triggerIcon(
                            emoji: "\u{1F4B3}",
                            colors: [Color(hex: 0x34C759), Color(hex: 0x30D158)],
                            size: 44
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Auto-log Apple Pay purchases")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text("Every tap-to-pay gets categorized and saved")
                                .font(.system(size: 12.5))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            } header: {
                Text("Suggested")
            }

            Section {
                ForEach(TriggerType.allCases.dropFirst(), id: \.self) { trigger in
                    Button {
                        onSelectTrigger(trigger)
                    } label: {
                        HStack(spacing: 12) {
                            triggerIcon(
                                emoji: trigger.icon,
                                colors: trigger.gradientColors,
                                size: 34
                            )

                            VStack(alignment: .leading, spacing: 1) {
                                Text(trigger.title)
                                    .font(.system(size: 14.5, weight: .medium))
                                    .foregroundStyle(.primary)
                                Text(trigger.subtitle)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Other Triggers")
            } footer: {
                Text("Automations run in the Shortcuts app and work even when Expense Tracker is closed.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Automate")
    }

    private func triggerIcon(emoji: String, colors: [Color], size: CGFloat) -> some View {
        Text(emoji)
            .font(.system(size: size * 0.45))
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: size * 0.27, style: .continuous))
    }
}

// MARK: - 4.7 Trigger Picker

struct TriggerPickerView: View {
    var onPick: (TriggerType) -> Void

    var body: some View {
        List {
            Section("When this happens...") {
                ForEach(TriggerType.allCases) { trigger in
                    Button {
                        onPick(trigger)
                    } label: {
                        HStack(spacing: 14) {
                            Text(trigger.icon)
                                .font(.system(size: 19))
                                .frame(width: 40, height: 40)
                                .background(
                                    LinearGradient(
                                        colors: trigger.gradientColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                                .shadow(color: trigger.gradientColors[0].opacity(0.25), radius: 5, y: 3)

                            VStack(alignment: .leading, spacing: 1) {
                                HStack(spacing: 6) {
                                    Text(trigger.title)
                                        .font(.system(size: 15.5, weight: .medium))
                                        .foregroundStyle(.primary)
                                    if trigger.isRecommended {
                                        Text("Recommended")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(.green)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.12))
                                            .clipShape(Capsule())
                                    }
                                }
                                Text(trigger.subtitle)
                                    .font(.system(size: 12.5))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("New Automation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 4.8 Automation Editor

struct AutomationEditorView: View {
    let trigger: TriggerType
    var onDone: () -> Void

    @State private var askBefore = false
    @State private var notifyWhenRun = true

    var body: some View {
        Form {
            Section("Trigger") {
                HStack(spacing: 12) {
                    Text(trigger.icon)
                        .font(.system(size: 16))
                        .frame(width: 34, height: 34)
                        .background(
                            LinearGradient(
                                colors: trigger.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(trigger.title)
                            .font(.system(size: 14.5, weight: .semibold))
                        Text(trigger.subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle(isOn: $askBefore) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Ask Before Running")
                        Text("Off runs silently in the background")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Then Do This") {
                actionChain
            }

            Section {
                Toggle(isOn: $notifyWhenRun) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Notify When Run")
                        Text("Shows a quiet confirmation banner")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Configure")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: onDone)
            }
        }
    }

    private var actionChain: some View {
        ForEach(ActionStep.defaultSteps) { step in
            HStack(alignment: .top, spacing: 12) {
                Text(step.icon)
                    .font(.system(size: 19))
                    .frame(width: 44, height: 44)
                    .background(step.color)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: step.color.opacity(0.3), radius: 5, y: 3)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(step.app.uppercased())
                            .font(.system(size: 10.5, weight: .semibold))
                            .foregroundStyle(step.color)
                            .tracking(0.3)

                        Spacer()

                        if step.isAI {
                            Text("\u{2728} Apple Intelligence")
                                .font(.system(size: 9.5, weight: .semibold))
                                .foregroundStyle(Color.purple)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1.5)
                                .background(Color.purple.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                    }

                    Text(step.title)
                        .font(.system(size: 14.5, weight: .semibold))

                    Text(step.detail)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
