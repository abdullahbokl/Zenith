import Foundation
import SwiftData

/// Abstracts data-access so `HabitViewModel` can be tested without a live SwiftData stack.
protocol HabitRepository {
  func fetchAll() throws -> [Habit]
  func insert(_ habit: Habit) throws
  func delete(_ habit: Habit) throws
  func deleteCheckIn(_ checkIn: CheckIn) throws
  func save() throws
}

/// Production implementation backed by SwiftData `ModelContext`.
final class SwiftDataHabitRepository: HabitRepository {

  private let modelContext: ModelContext

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  func fetchAll() throws -> [Habit] {
    let descriptor = FetchDescriptor<Habit>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    return try modelContext.fetch(descriptor)
  }

  func insert(_ habit: Habit) throws {
    modelContext.insert(habit)
  }

  func delete(_ habit: Habit) throws {
    modelContext.delete(habit)
  }

  func deleteCheckIn(_ checkIn: CheckIn) throws {
    modelContext.delete(checkIn)
  }

  func save() throws {
    try modelContext.save()
  }
}
