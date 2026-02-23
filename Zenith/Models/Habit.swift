import Foundation
import SwiftData

/// Core data model for a trackable habit.
@Model
final class Habit {

  var id: UUID
  var title: String
  var icon: String
  var color: String
  var createdAt: Date

  @Relationship(deleteRule: .cascade, inverse: \CheckIn.habit)
  var checkIns: [CheckIn]

  init(
    title: String,
    icon: String = "star.fill",
    color: String = "#6C63FF",
    createdAt: Date = .now,
    checkIns: [CheckIn] = []
  ) {
    self.id = UUID()
    self.title = title
    self.icon = icon
    self.color = color
    self.createdAt = createdAt
    self.checkIns = checkIns
  }
}

// MARK: - Computed Helpers

extension Habit {

  var todayCheckedIn: Bool {
    let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: .now)
    return checkIns.contains { $0.calendarDate == todayComponents }
  }

  var completedDaysCount: Int {
    Set(checkIns.map { $0.calendarDate }).count
  }

  var currentStreak: Int {
    let calendar = Calendar.current
    let uniqueDates = Set(checkIns.map { calendar.startOfDay(for: $0.date) })
      .sorted(by: >)

    guard let first = uniqueDates.first else { return 0 }

    let todayStart = calendar.startOfDay(for: .now)
    let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
    guard first >= yesterdayStart else { return 0 }

    var streak = 1
    for i in 1..<uniqueDates.count {
      let expected = calendar.date(byAdding: .day, value: -i, to: first)!
      if calendar.isDate(uniqueDates[i], inSameDayAs: expected) {
        streak += 1
      } else {
        break
      }
    }
    return streak
  }
}
