import Foundation
import SwiftData

/// Represents a single day a habit was completed.
@Model
final class CheckIn {

  var id: UUID
  var date: Date
  var habit: Habit?

  init(date: Date = .now, habit: Habit? = nil) {
    self.id = UUID()
    self.date = date
    self.habit = habit
  }
}

extension CheckIn {

  var calendarDate: DateComponents {
    Calendar.current.dateComponents([.year, .month, .day], from: date)
  }
}
