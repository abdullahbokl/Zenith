import SwiftUI

/// Main dashboard listing all habits with progress rings.
struct DashboardView: View {

  @Bindable var viewModel: HabitViewModel
  @State private var showAddSheet = false

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      AppTheme.background
        .ignoresSafeArea()

      ScrollView {
        LazyVStack(spacing: AppTheme.spacing) {
          headerSection
          habitsList
        }
        .padding(.horizontal, AppTheme.spacing)
        .padding(.bottom, 100)
      }

      addButton
    }
    .task {
      await viewModel.fetchHabits()
    }
    .sheet(isPresented: $showAddSheet) {
      AddHabitSheet(viewModel: viewModel)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppTheme.surface)
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
      Text(greetingText)
        .font(AppTheme.captionFont)
        .foregroundStyle(AppTheme.textSecondary)

      Text("Your Habits")
        .font(AppTheme.titleFont)
        .foregroundStyle(AppTheme.textPrimary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.top, AppTheme.spacing)
  }

  // MARK: - Habits List

  @ViewBuilder
  private var habitsList: some View {
    if viewModel.habits.isEmpty {
      emptyState
    } else {
      ForEach(viewModel.habits, id: \.id) { habit in
        HabitCard(habit: habit) {
          Task { await viewModel.toggleCheckIn(for: habit) }
        }
        .transition(
          .asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .slide.combined(with: .opacity)
          ))
      }
      .animation(.spring(duration: 0.4), value: viewModel.habits.count)
    }
  }

  // MARK: - Empty State

  private var emptyState: some View {
    VStack(spacing: AppTheme.spacing) {
      Spacer().frame(height: 60)

      Image(systemName: "sparkles")
        .font(.system(size: 64))
        .foregroundStyle(AppTheme.accentGradient)
        .symbolEffect(.pulse, options: .repeating)

      Text("No habits yet")
        .font(AppTheme.headlineFont)
        .foregroundStyle(AppTheme.textPrimary)

      Text("Tap + to create your first habit\nand start building momentum.")
        .font(AppTheme.bodyFont)
        .foregroundStyle(AppTheme.textSecondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 40)
  }

  // MARK: - FAB

  private var addButton: some View {
    Button {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      showAddSheet = true
    } label: {
      Image(systemName: "plus")
        .font(.system(size: 24, weight: .bold))
        .foregroundStyle(.white)
        .frame(width: 60, height: 60)
        .background(AppTheme.accentGradient)
        .clipShape(Circle())
        .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, y: 6)
    }
    .buttonStyle(ScaleButtonStyle())
    .padding(.trailing, AppTheme.spacing)
    .padding(.bottom, AppTheme.spacing)
  }

  // MARK: - Helpers

  private var greetingText: String {
    let hour = Calendar.current.component(.hour, from: .now)
    switch hour {
    case 5..<12: return "Good Morning ☀️"
    case 12..<17: return "Good Afternoon 🌤️"
    case 17..<21: return "Good Evening 🌅"
    default: return "Good Night 🌙"
    }
  }
}
