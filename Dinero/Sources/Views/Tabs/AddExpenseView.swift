import SwiftUI

struct AddExpenseView: View {
    @Environment(ExpenseStore.self) private var store
    @State private var amountText = "0"
    @State private var selectedCategory: Category?
    @State private var note = ""
    @State private var showSuccess = false
    var onDismiss: () -> Void

    private var amountValue: Decimal {
        Decimal(string: amountText) ?? 0
    }

    private var canSave: Bool {
        amountValue > 0 && selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                if showSuccess {
                    successOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else {
                    mainContent
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showSuccess)
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    amountDisplay
                    categoryGrid
                    noteField
                }
                .padding(.horizontal, 20)
            }

            VStack(spacing: 16) {
                numpad
                saveButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Amount Display

    private var amountDisplay: some View {
        VStack(spacing: 4) {
            Text("Amount")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.labelSecondary)

            Text("$\(amountText)")
                .font(.system(size: 52, weight: .bold))
                .tracking(-2)
                .foregroundStyle(Color.labelPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(.vertical, 20)
        .accessibilityLabel("Amount: $\(amountText)")
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CATEGORY")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.labelSecondary)
                .tracking(0.3)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(Category.allCases) { cat in
                    CategoryButton(
                        category: cat,
                        isSelected: selectedCategory == cat
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = cat
                        }
                    }
                }
            }
        }
    }

    // MARK: - Note Field

    private var noteField: some View {
        GlassCard {
            HStack(spacing: 10) {
                Image(systemName: "doc.text")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.labelSecondary)
                TextField("Add a note", text: $note)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.labelPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    // MARK: - Numpad

    private var numpad: some View {
        let keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "\u{232B}"]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(keys, id: \.self) { key in
                Button {
                    handleKey(key)
                } label: {
                    Text(key)
                        .font(.system(size: key == "\u{232B}" ? 18 : 22, weight: .medium))
                        .foregroundStyle(key == "\u{232B}" ? Color.danger : Color.labelPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            key == "\u{232B}"
                                ? Color.danger.opacity(0.1)
                                : Color(hex: 0x8E8E93).opacity(0.08)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(key == "\u{232B}" ? "Backspace" : key)
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: save) {
            Text("Save Expense")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(canSave ? .white : Color.labelTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    canSave
                        ? AnyShapeStyle(LinearGradient(
                            colors: [Color.accentBlue, Color.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        : AnyShapeStyle(Color(hex: 0x8E8E93).opacity(0.15))
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .disabled(!canSave)
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.success, Color.successAlt],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("Expense Saved")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.labelPrimary)

            Text("\(AmountFormatter.format(amountValue)) added")
                .font(.system(size: 15))
                .foregroundStyle(Color.labelSecondary)
        }
    }

    // MARK: - Logic

    private func handleKey(_ key: String) {
        if key == "\u{232B}" {
            if amountText.count > 1 {
                amountText.removeLast()
            } else {
                amountText = "0"
            }
            return
        }

        if key == "." {
            if amountText.contains(".") { return }
            amountText += "."
            return
        }

        if let dotIndex = amountText.firstIndex(of: ".") {
            let decimals = amountText[amountText.index(after: dotIndex)...]
            if decimals.count >= 2 { return }
        }

        if amountText == "0" {
            amountText = key
        } else {
            amountText += key
        }
    }

    private func save() {
        guard let category = selectedCategory, amountValue > 0 else { return }
        store.addTransaction(
            merchantName: note.isEmpty ? category.label : note,
            amount: amountValue,
            category: category,
            note: note.isEmpty ? nil : note
        )
        showSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            onDismiss()
        }
    }
}

// MARK: - Category Button

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? category.color : Color(hex: 0x6B7280))
                Text(category.shortLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? category.color : Color(hex: 0x6B7280))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? category.color.opacity(0.1)
                    : Color(hex: 0x8E8E93).opacity(0.08)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? category.color : .clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.0 : 0.96)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Category: \(category.label)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
