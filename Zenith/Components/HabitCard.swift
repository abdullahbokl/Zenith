import SwiftData
import SwiftUI

/// Card displaying a habit with icon, title, streak, and progress ring.
struct HabitCard: View {

  let habit: Habit
  let onToggle: () -> Void

  private var monthlyProgress: Double {
    let calendar = Calendar.current
    let today = Date.now
    let dayOfMonth = calendar.component(.day, from: today)
    guard dayOfMonth > 0 else { return 0 }

    let currentMonth = calendar.component(.month, from: today)
    let currentYear = calendar.component(.year, from: today)
    let thisMonthCount = habit.checkIns.filter { checkIn in
      let comps = calendar.dateComponents([.year, .month], from: checkIn.date)
      return comps.year == currentYear && comps.month == currentMonth
    }.count

    return min(Double(thisMonthCount) / Double(dayOfMonth), 1.0)
  }

  var body: some View {
    Button(action: onToggle) {
      HStack(spacing: AppTheme.spacing) {
        iconBadge
        titleSection
        Spacer()
        CircularProgressView(
          progress: monthlyProgress,
          lineWidth: 4,
          gradient: habitGradient,
          size: AppTheme.iconSize
        )
      }
      .padding(AppTheme.spacing)
      .background(AppTheme.cardGradient)
      .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
      .overlay(
        RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
          .strokeBorder(
            habit.todayCheckedIn
              ? Color(hex: habit.color).opacity(0.4)
              : Color.clear,
            lineWidth: 1.5
          )
      )
    }
    .buttonStyle(ScaleButtonStyle())
  }

  // MARK: - Sub-views

  private var iconBadge: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(hex: habit.color).opacity(0.15))
        .frame(width: AppTheme.iconSize, height: AppTheme.iconSize)

      Image(systemName: habit.icon)
        .font(.system(size: 20, weight: .semibold))
        .foregroundStyle(Color(hex: habit.color))
    }
  }

  private var titleSection: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(habit.title)
        .font(AppTheme.headlineFont)
        .foregroundStyle(AppTheme.textPrimary)

      Text(subtitleText)
        .font(AppTheme.captionFont)
        .foregroundStyle(AppTheme.textSecondary)
    }
  }

  private var subtitleText: String {
    habit.todayCheckedIn
      ? "✅ Done today · \(habit.currentStreak) day streak"
      : "\(habit.completedDaysCount) days completed"
  }

  private var habitGradient: LinearGradient {
    LinearGradient(
      colors: [Color(hex: habit.color), Color(hex: habit.color).opacity(0.6)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}

#Preview {
  HabitCard(habit: .init(title: "Morning Run", icon: "figure.run", color: "#FF6B6B")) {}
    .padding()
    .background(AppTheme.background)
    .modelContainer(for: Habit.self, inMemory: true)
}
