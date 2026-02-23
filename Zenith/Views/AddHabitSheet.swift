import SwiftUI

/// Sheet for creating a new habit — title, icon, and colour picker.
struct AddHabitSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: HabitViewModel

    @State private var title = ""
    @State private var selectedIcon = AppTheme.habitIcons[0]
    @State private var selectedColor = AppTheme.habitColors[0]

    private var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacing * 1.5) {
                    previewBadge
                    titleField
                    iconPicker
                    colorPicker

                    ThemeButton("Create Habit", icon: "checkmark.circle.fill") {
                        guard isValid else { return }
                        Task {
                            await viewModel.addHabit(
                                title: title.trimmingCharacters(in: .whitespaces),
                                icon: selectedIcon,
                                color: selectedColor
                            )
                            dismiss()
                        }
                    }
                    .opacity(isValid ? 1 : 0.5)
                    .disabled(!isValid)
                }
                .padding(AppTheme.spacing)
            }
            .background(AppTheme.surface.ignoresSafeArea())
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .toolbarBackground(AppTheme.surface, for: .navigationBar)
        }
    }

    // MARK: - Preview Badge

    private var previewBadge: some View {
        ZStack {
            Circle()
                .fill(Color(hex: selectedColor).opacity(0.15))
                .frame(width: 88, height: 88)

            Image(systemName: selectedIcon)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(Color(hex: selectedColor))
        }
        .animation(.spring(duration: 0.3), value: selectedIcon)
        .animation(.spring(duration: 0.3), value: selectedColor)
    }

    // MARK: - Title Field

    private var titleField: some View {
        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
            Text("TITLE")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)

            TextField("e.g. Morning Run", text: $title)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textPrimary)
                .padding()
                .background(AppTheme.surfaceLight)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            Color(hex: selectedColor).opacity(0.3),
                            lineWidth: 1
                        )
                )
        }
    }

    // MARK: - Icon Picker

    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
            Text("ICON")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6),
                spacing: 12
            ) {
                ForEach(AppTheme.habitIcons, id: \.self) { icon in
                    iconCell(icon)
                }
            }
        }
    }

    private func iconCell(_ icon: String) -> some View {
        let isSelected = icon == selectedIcon
        return Button {
            withAnimation(.spring(duration: 0.25)) { selectedIcon = icon }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(
                    isSelected ? Color(hex: selectedColor) : AppTheme.textSecondary
                )
                .frame(width: 44, height: 44)
                .background(
                    isSelected
                        ? Color(hex: selectedColor).opacity(0.15)
                        : AppTheme.surfaceLight
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            isSelected ? Color(hex: selectedColor).opacity(0.5) : .clear,
                            lineWidth: 1.5
                        )
                )
        }
    }

    // MARK: - Colour Picker

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
            Text("COLOR")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6),
                spacing: 12
            ) {
                ForEach(AppTheme.habitColors, id: \.self) { hex in
                    colorCell(hex)
                }
            }
        }
    }

    private func colorCell(_ hex: String) -> some View {
        let isSelected = hex == selectedColor
        return Button {
            withAnimation(.spring(duration: 0.25)) { selectedColor = hex }
        } label: {
            Circle()
                .fill(Color(hex: hex))
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .strokeBorder(.white.opacity(isSelected ? 0.8 : 0), lineWidth: 2.5)
                )
                .scaleEffect(isSelected ? 1.15 : 1)
        }
    }
}
