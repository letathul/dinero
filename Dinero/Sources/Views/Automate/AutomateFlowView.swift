import SwiftUI

enum AutomateStep: Equatable {
    case entry
    case triggerPicker
    case editor
    case confirmation
    case preview
}

struct AutomateFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: AutomateStep = .entry
    @State private var selectedTrigger: TriggerType = .applePayTransaction

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .entry:
                    AutomateEntryView(
                        onStart: { step = .triggerPicker },
                        onSelectTrigger: { trigger in
                            selectedTrigger = trigger
                            step = .editor
                        }
                    )
                case .triggerPicker:
                    TriggerPickerView(
                        onPick: { trigger in
                            selectedTrigger = trigger
                            step = .editor
                        },
                        onBack: { step = .entry }
                    )
                case .editor:
                    AutomationEditorView(
                        trigger: selectedTrigger,
                        onBack: { step = .triggerPicker },
                        onDone: { step = .confirmation }
                    )
                case .confirmation:
                    ConfirmationView(
                        trigger: selectedTrigger,
                        onFinish: { step = .preview }
                    )
                case .preview:
                    LivePreviewView(
                        trigger: selectedTrigger,
                        onRestart: { step = .triggerPicker },
                        onDone: { dismiss() }
                    )
                }
            }
            .animation(.easeInOut(duration: 0.25), value: step)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if step == .entry {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }
}

// MARK: - 4.6 Entry Screen

struct AutomateEntryView: View {
    var onStart: () -> Void
    var onSelectTrigger: (TriggerType) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(
                    title: "Automate",
                    subtitle: "Log expenses without opening the app"
                )

                sectionLabel("Suggested")
                    .padding(.bottom, 8)

                GlassCard {
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
                                    .foregroundStyle(Color.labelPrimary)
                                Text("Every tap-to-pay gets categorized and saved")
                                    .font(.system(size: 12.5))
                                    .foregroundStyle(Color.labelSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.labelTertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }

                sectionLabel("Other Triggers")
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                GlassCard {
                    VStack(spacing: 0) {
                        ForEach(Array(TriggerType.allCases.dropFirst().enumerated()), id: \.element) { index, trigger in
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
                                            .foregroundStyle(Color.labelPrimary)
                                        Text(trigger.subtitle)
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.labelSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.labelTertiary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)

                            if index < TriggerType.allCases.count - 2 {
                                Divider().padding(.leading, 62)
                            }
                        }
                    }
                }

                Text("Automations run in the Shortcuts app and work even when Expense Tracker is closed.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.labelSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.labelSecondary)
            .tracking(0.4)
            .padding(.leading, 4)
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
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            VStack(alignment: .leading, spacing: 8) {
                Text("WHEN THIS HAPPENS\u{2026}")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.labelSecondary)
                    .tracking(0.4)
                    .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 10)

            ScrollView {
                VStack(spacing: 0) {
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
                                            .foregroundStyle(Color.labelPrimary)
                                        if trigger.isRecommended {
                                            Text("Recommended")
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundStyle(Color.success)
                                                .padding(.horizontal, 7)
                                                .padding(.vertical, 2)
                                                .background(Color.success.opacity(0.12))
                                                .clipShape(Capsule())
                                        }
                                    }
                                    Text(trigger.subtitle)
                                        .font(.system(size: 12.5))
                                        .foregroundStyle(Color.labelSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.labelTertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 70)
                    }
                }
            }
        }
        .background(
            LinearGradient(
                colors: [Color(hex: 0xFAFAFC), Color.bgPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var headerBar: some View {
        HStack {
            Button("Cancel", action: onBack)
                .font(.system(size: 15.5))
                .foregroundStyle(Color.accentBlue)

            Spacer()

            Text("New Automation")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.labelPrimary)

            Spacer()

            Color.clear.frame(width: 52)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - 4.8 Automation Editor

struct AutomationEditorView: View {
    let trigger: TriggerType
    var onBack: () -> Void
    var onDone: () -> Void

    @State private var askBefore = false
    @State private var notifyWhenRun = true

    var body: some View {
        VStack(spacing: 0) {
            editorHeader

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    sectionLabel("Trigger")
                        .padding(.bottom, 8)

                    triggerChip
                        .padding(.bottom, 20)

                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Ask Before Running")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.labelPrimary)
                            Text("Off runs silently in the background")
                                .font(.system(size: 11.5))
                                .foregroundStyle(Color.labelSecondary)
                        }
                        Spacer()
                        Toggle("", isOn: $askBefore)
                            .labelsHidden()
                            .tint(Color.success)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 18)

                    sectionLabel("Then Do This")
                        .padding(.bottom, 8)

                    actionChain

                    addActionButton
                        .padding(.top, 10)

                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Notify When Run")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.labelPrimary)
                            Text("Shows a quiet confirmation banner")
                                .font(.system(size: 11.5))
                                .foregroundStyle(Color.labelSecondary)
                        }
                        Spacer()
                        Toggle("", isOn: $notifyWhenRun)
                            .labelsHidden()
                            .tint(Color.success)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(hex: 0xFAFAFC), Color.bgPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var editorHeader: some View {
        HStack {
            Button("Back", action: onBack)
                .font(.system(size: 15.5))
                .foregroundStyle(Color.accentBlue)

            Spacer()

            Text("Configure")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.labelPrimary)

            Spacer()

            Button("Done", action: onDone)
                .font(.system(size: 15.5, weight: .semibold))
                .foregroundStyle(Color.accentBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var triggerChip: some View {
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
                    .foregroundStyle(Color.labelPrimary)
                Text(trigger.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: 0x6B7280))
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: trigger.gradientColors.map { $0.opacity(0.1) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(trigger.gradientColors[0].opacity(0.2), lineWidth: 1)
        )
    }

    private var actionChain: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(width: 2)
                .padding(.leading, 27)
                .padding(.vertical, 22)

            VStack(spacing: 10) {
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
                                        .foregroundStyle(Color(hex: 0xAF52DE))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1.5)
                                        .background(Color(hex: 0xAF52DE).opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                            }

                            Text(step.title)
                                .font(.system(size: 14.5, weight: .semibold))
                                .foregroundStyle(Color.labelPrimary)

                            Text(step.detail)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.labelSecondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 1.5, y: 1)
                    }
                }
            }
        }
    }

    private var addActionButton: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.accentBlue)
                .frame(width: 44, height: 44)
                .background(Color.accentBlue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text("Add Action")
                .font(.system(size: 14.5, weight: .medium))
                .foregroundStyle(Color.accentBlue)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.accentBlue.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.accentBlue.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
        )
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.labelSecondary)
            .tracking(0.4)
            .padding(.leading, 4)
    }
}
