import SwiftUI

/// Detail view showing comprehensive stats and check-in history for a single habit.
struct HabitDetailView: View {

  let habit: Habit
  @Bindable var viewModel: HabitViewModel

  @Environment(\.dismiss) private var dismiss
  @State private var showEditSheet = false
  @State private var showDeleteConfirmation = false

  private var habitColor: Color { Color(hex: habit.color) }

  var body: some View {
    ScrollView {
      VStack(spacing: AppTheme.spacing * 1.5) {
        heroSection
        statsGrid
        CalendarHeatmapView(
          checkIns: habit.checkIns,
          color: habitColor
        )
        actionButtons
      }
      .padding(AppTheme.spacing)
      .padding(.bottom, 40)
    }
    .background(AppTheme.background.ignoresSafeArea())
    .navigationTitle(habit.title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(AppTheme.background, for: .navigationBar)
    .sheet(isPresented: $showEditSheet) {
      EditHabitSheet(viewModel: viewModel, habit: habit)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppTheme.surface)
    }
    .confirmationDialog(
      "Delete \"\(habit.title)\"?",
      isPresented: $showDeleteConfirmation,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        viewModel.deleteHabit(habit)
        dismiss()
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This will permanently remove this habit and all its check-in history.")
    }
  }

  // MARK: - Hero

  private var heroSection: some View {
    VStack(spacing: AppTheme.spacing) {
      ZStack {
        Circle()
          .fill(habitColor.opacity(0.15))
          .frame(width: 100, height: 100)

        Image(systemName: habit.icon)
          .font(.system(size: 44, weight: .semibold))
          .foregroundStyle(habitColor)
      }

      VStack(spacing: 4) {
        Text(habit.title)
          .font(AppTheme.titleFont)
          .foregroundStyle(AppTheme.textPrimary)

        Text("Created \(habit.createdAt.formatted(.dateTime.month(.wide).day().year()))")
          .font(AppTheme.captionFont)
          .foregroundStyle(AppTheme.textSecondary)
      }

      if habit.todayCheckedIn {
        Label("Done today", systemImage: "checkmark.circle.fill")
          .font(AppTheme.bodyFont)
          .foregroundStyle(AppTheme.success)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(AppTheme.success.opacity(0.15))
          .clipShape(Capsule())
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AppTheme.spacing)
  }

  // MARK: - Stats Grid

  private var statsGrid: some View {
    LazyVGrid(
      columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
      spacing: 12
    ) {
      statCard(
        title: "Current Streak", value: "\(habit.currentStreak)", unit: "days",
        icon: "flame.fill", color: .orange)
      statCard(
        title: "Total Check-ins", value: "\(habit.completedDaysCount)", unit: "days",
        icon: "checkmark.circle.fill", color: AppTheme.success)
      statCard(
        title: "This Month", value: "\(monthlyCount)", unit: "days",
        icon: "calendar", color: habitColor)
    }
  }

  private var monthlyCount: Int {
    let calendar = Calendar.current
    let now = Date.now
    let currentMonth = calendar.component(.month, from: now)
    let currentYear = calendar.component(.year, from: now)
    return habit.checkIns.filter { checkIn in
      let comps = calendar.dateComponents([.year, .month], from: checkIn.date)
      return comps.year == currentYear && comps.month == currentMonth
    }.count
  }

  private func statCard(title: String, value: String, unit: String, icon: String, color: Color)
    -> some View
  {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundStyle(color)

      Text(value)
        .font(.system(size: 24, weight: .bold, design: .rounded))
        .foregroundStyle(AppTheme.textPrimary)

      Text(title)
        .font(AppTheme.captionFont)
        .foregroundStyle(AppTheme.textSecondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AppTheme.spacing)
    .background(AppTheme.cardGradient)
    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
  }

  // MARK: - Actions

  private var actionButtons: some View {
    VStack(spacing: 12) {
      ThemeButton("Edit Habit", icon: "pencil") {
        showEditSheet = true
      }

      Button {
        showDeleteConfirmation = true
      } label: {
        HStack(spacing: AppTheme.smallSpacing) {
          Image(systemName: "trash.fill")
            .font(.system(size: 16, weight: .semibold))
          Text("Delete Habit")
            .font(AppTheme.headlineFont)
        }
        .foregroundStyle(AppTheme.danger)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.danger.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
      }
      .buttonStyle(ScaleButtonStyle())
    }
  }
}
