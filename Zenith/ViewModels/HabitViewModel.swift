import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.boklo.zenith", category: "HabitViewModel")

/// Central ViewModel for habit CRUD operations.
@MainActor @Observable
final class HabitViewModel {

  // MARK: - Published State

  var habits: [Habit] = []
  var isLoading = false
  var searchText = ""
  var sortOption: SortOption = .dateCreated

  enum SortOption: String, CaseIterable, Identifiable {
    case dateCreated = "Date Created"
    case name = "Name"
    case streak = "Streak"
    case completion = "Completion"

    var id: String { rawValue }
  }

  var filteredHabits: [Habit] {
    var result = habits

    if !searchText.isEmpty {
      result = result.filter {
        $0.title.localizedCaseInsensitiveContains(searchText)
      }
    }

    switch sortOption {
    case .dateCreated:
      result.sort { $0.createdAt > $1.createdAt }
    case .name:
      result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    case .streak:
      result.sort { $0.currentStreak > $1.currentStreak }
    case .completion:
      result.sort { $0.completedDaysCount > $1.completedDaysCount }
    }

    return result
  }

  private let repository: HabitRepository

  init(repository: HabitRepository) {
    self.repository = repository
  }

  // MARK: - CRUD

  func fetchHabits() {
    isLoading = true
    defer { isLoading = false }

    do {
      habits = try repository.fetchAll()
    } catch {
      logger.error("Failed to fetch habits: \(error.localizedDescription)")
    }
  }

  func addHabit(title: String, icon: String, color: String) {
    let habit = Habit(title: title, icon: icon, color: color)
    do {
      try repository.insert(habit)
      try repository.save()
      fetchHabits()
    } catch {
      logger.error("Failed to add habit: \(error.localizedDescription)")
    }
  }

  func updateHabit(_ habit: Habit, title: String, icon: String, color: String) {
    habit.title = title
    habit.icon = icon
    habit.color = color
    do {
      try repository.save()
      fetchHabits()
    } catch {
      logger.error("Failed to update habit: \(error.localizedDescription)")
    }
  }

  func toggleCheckIn(for habit: Habit) {
    let calendar = Calendar.current
    let todayComponents = calendar.dateComponents([.year, .month, .day], from: .now)

    if let existing = habit.checkIns.first(where: { $0.calendarDate == todayComponents }) {
      do {
        try repository.deleteCheckIn(existing)
      } catch {
        logger.error("Failed to remove check-in: \(error.localizedDescription)")
      }
    } else {
      let checkIn = CheckIn(date: .now, habit: habit)
      habit.checkIns.append(checkIn)
    }

    do {
      try repository.save()
      fetchHabits()
    } catch {
      logger.error("Failed to toggle check-in: \(error.localizedDescription)")
    }
  }

  func deleteHabit(_ habit: Habit) {
    do {
      try repository.delete(habit)
      try repository.save()
      fetchHabits()
    } catch {
      logger.error("Failed to delete habit: \(error.localizedDescription)")
    }
  }
}
