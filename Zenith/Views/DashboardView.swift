import SwiftUI

/// Main dashboard listing all habits with progress rings, search, sort, and pull-to-refresh.
struct DashboardView: View {

  @Bindable var viewModel: HabitViewModel
  @State private var showAddSheet = false
  @State private var habitToDelete: Habit?

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      AppTheme.background
        .ignoresSafeArea()

      ScrollView {
        LazyVStack(spacing: AppTheme.spacing) {
          headerSection
          sortBar

          if viewModel.isLoading {
            loadingState
          } else if viewModel.filteredHabits.isEmpty {
            emptyState
          } else {
            habitsList
          }
        }
        .padding(.horizontal, AppTheme.spacing)
        .padding(.bottom, 100)
      }
      .refreshable {
        viewModel.fetchHabits()
      }
      .searchable(
        text: $viewModel.searchText,
        placement: .navigationBarDrawer(displayMode: .automatic),
        prompt: "Search habits..."
      )

      addButton
    }
    .task {
      viewModel.fetchHabits()
    }
    .sheet(isPresented: $showAddSheet) {
      AddHabitSheet(viewModel: viewModel)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppTheme.surface)
    }
    .confirmationDialog(
      "Delete \"\(habitToDelete?.title ?? "")\"?",
      isPresented: .init(
        get: { habitToDelete != nil },
        set: { if !$0 { habitToDelete = nil } }
      ),
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        if let habit = habitToDelete {
          withAnimation { viewModel.deleteHabit(habit) }
        }
        habitToDelete = nil
      }
      Button("Cancel", role: .cancel) {
        habitToDelete = nil
      }
    } message: {
      Text("This will permanently remove this habit and all its check-in history.")
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

  // MARK: - Sort Bar

  private var sortBar: some View {
    HStack {
      Text("\(viewModel.filteredHabits.count) habits")
        .font(AppTheme.captionFont)
        .foregroundStyle(AppTheme.textSecondary)

      Spacer()

      Menu {
        ForEach(HabitViewModel.SortOption.allCases) { option in
          Button {
            withAnimation { viewModel.sortOption = option }
          } label: {
            Label(
              option.rawValue,
              systemImage: viewModel.sortOption == option ? "checkmark" : "")
          }
        }
      } label: {
        HStack(spacing: 4) {
          Image(systemName: "arrow.up.arrow.down")
          Text(viewModel.sortOption.rawValue)
        }
        .font(AppTheme.captionFont)
        .foregroundStyle(AppTheme.accent)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppTheme.accent.opacity(0.12))
        .clipShape(Capsule())
      }
      .accessibilityLabel("Sort habits")
      .accessibilityHint("Currently sorted by \(viewModel.sortOption.rawValue)")
    }
  }

  // MARK: - Habits List

  @ViewBuilder
  private var habitsList: some View {
    ForEach(viewModel.filteredHabits, id: \.id) { habit in
      NavigationLink {
        HabitDetailView(habit: habit, viewModel: viewModel)
      } label: {
        HabitCard(habit: habit) {
          UIImpactFeedbackGenerator(style: .light).impactOccurred()
          viewModel.toggleCheckIn(for: habit)
        }
      }
      .buttonStyle(.plain)
      .swipeActions(edge: .trailing, allowsFullSwipe: false) {
        Button(role: .destructive) {
          habitToDelete = habit
        } label: {
          Label("Delete", systemImage: "trash.fill")
        }
      }
      .contextMenu {
        Button {
          UIImpactFeedbackGenerator(style: .light).impactOccurred()
          viewModel.toggleCheckIn(for: habit)
        } label: {
          Label(
            habit.todayCheckedIn ? "Undo Check-in" : "Check In",
            systemImage: habit.todayCheckedIn ? "xmark.circle" : "checkmark.circle.fill"
          )
        }

        Button(role: .destructive) {
          habitToDelete = habit
        } label: {
          Label("Delete", systemImage: "trash.fill")
        }
      }
      .transition(
        .asymmetric(
          insertion: .scale.combined(with: .opacity),
          removal: .slide.combined(with: .opacity)
        ))
    }
    .animation(.spring(duration: 0.4), value: viewModel.filteredHabits.count)
  }

  // MARK: - Loading State

  private var loadingState: some View {
    VStack(spacing: AppTheme.spacing) {
      Spacer().frame(height: 60)
      ProgressView()
        .tint(AppTheme.accent)
        .scaleEffect(1.5)
      Text("Loading habits...")
        .font(AppTheme.bodyFont)
        .foregroundStyle(AppTheme.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 40)
  }

  // MARK: - Empty State

  private var emptyState: some View {
    VStack(spacing: AppTheme.spacing) {
      Spacer().frame(height: 60)

      Button {
        showAddSheet = true
      } label: {
        Image(systemName: "sparkles")
          .font(.system(size: 64))
          .foregroundStyle(AppTheme.accentGradient)
          .symbolEffect(.pulse, options: .repeating)
      }
      .accessibilityLabel("Create your first habit")

      Text(viewModel.searchText.isEmpty ? "No habits yet" : "No matching habits")
        .font(AppTheme.headlineFont)
        .foregroundStyle(AppTheme.textPrimary)

      if viewModel.searchText.isEmpty {
        Text("Tap + to create your first habit\nand start building momentum.")
          .font(AppTheme.bodyFont)
          .foregroundStyle(AppTheme.textSecondary)
          .multilineTextAlignment(.center)
      }
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
    .accessibilityLabel("Add new habit")
    .accessibilityHint("Opens a form to create a new habit")
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
