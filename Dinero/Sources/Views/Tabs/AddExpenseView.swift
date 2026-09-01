import SwiftUI

struct AddExpenseView: View {
    @Environment(ExpenseStore.self) private var store
    @State private var amount: Decimal = 0
    @State private var selectedCategory: Category?
    @State private var note = ""
    @State private var showSuccess = false
    @FocusState private var amountFocused: Bool
    var onDismiss: () -> Void

    private var canSave: Bool {
        amount > 0 && selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

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
                    amountField
                    categoryGrid
                    noteField
                }
                .padding(.horizontal, 20)
            }

            saveButton
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
    }

    // MARK: - Amount Field

    private var amountField: some View {
        VStack(spacing: 4) {
            Text("Amount")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("$0.00", value: $amount, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
                .font(.system(size: 42, weight: .bold))
                .multilineTextAlignment(.center)
                .focused($amountFocused)
        }
        .padding(.vertical, 20)
        .onAppear { amountFocused = true }
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CATEGORY")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
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
        HStack(spacing: 10) {
            Image(systemName: "doc.text")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
            TextField("Add a note", text: $note)
                .font(.system(size: 15))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassCard()
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: save) {
            Text("Save Expense")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(canSave ? .white : .tertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    canSave
                        ? AnyShapeStyle(LinearGradient(
                            colors: [Color.accentBlue, Color.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        : AnyShapeStyle(Color(.systemFill))
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
                        colors: [Color.green, Color.green],
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

            Text("\(AmountFormatter.format(amount)) added")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Logic

    private func save() {
        guard let category = selectedCategory, amount > 0 else { return }
        store.addTransaction(
            merchantName: note.isEmpty ? category.label : note,
            amount: amount,
            category: category,
            note: note.isEmpty ? nil : note
        )
        showSuccess = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
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
                    .foregroundStyle(isSelected ? category.color : .secondary)
                Text(category.shortLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? category.color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? category.color.opacity(0.1)
                    : Color(.systemFill)
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
