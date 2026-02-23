import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.boklo.zenith", category: "HabitViewModel")

/// Central ViewModel for habit CRUD operations.
@Observable
final class HabitViewModel {

  var habits: [Habit] = []
  var isLoading = false

  private let modelContext: ModelContext

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  // MARK: - CRUD

  func fetchHabits() async {
    isLoading = true
    defer { isLoading = false }

    let descriptor = FetchDescriptor<Habit>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )

    do {
      habits = try modelContext.fetch(descriptor)
    } catch {
      logger.error("Failed to fetch habits: \(error.localizedDescription)")
    }
  }

  func addHabit(title: String, icon: String, color: String) async {
    let habit = Habit(title: title, icon: icon, color: color)
    modelContext.insert(habit)
    saveContext()
    await fetchHabits()
  }

  func toggleCheckIn(for habit: Habit) async {
    let calendar = Calendar.current
    let todayComponents = calendar.dateComponents([.year, .month, .day], from: .now)

    if let existing = habit.checkIns.first(where: { $0.calendarDate == todayComponents }) {
      modelContext.delete(existing)
    } else {
      let checkIn = CheckIn(date: .now, habit: habit)
      habit.checkIns.append(checkIn)
    }

    saveContext()
    await fetchHabits()
  }

  func deleteHabit(_ habit: Habit) {
    modelContext.delete(habit)
    saveContext()
    habits.removeAll { $0.id == habit.id }
  }

  // MARK: - Private

  private func saveContext() {
    do {
      try modelContext.save()
    } catch {
      logger.error("Failed to save context: \(error.localizedDescription)")
    }
  }
}
