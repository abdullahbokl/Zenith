import SwiftUI

/// Calendar heatmap showing check-in history for a habit.
struct CalendarHeatmapView: View {

  let checkIns: [CheckIn]
  let color: Color
  let months: Int

  init(checkIns: [CheckIn], color: Color, months: Int = 3) {
    self.checkIns = checkIns
    self.color = color
    self.months = months
  }

  private var checkedInDates: Set<DateComponents> {
    Set(checkIns.map { $0.calendarDate })
  }

  private var weeks: [[Date?]] {
    let calendar = Calendar.current
    let today = Date.now
    guard let startDate = calendar.date(byAdding: .month, value: -months, to: today) else {
      return []
    }

    let adjustedStart = calendar.date(
      from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate))!

    var weeks: [[Date?]] = []
    var currentWeek: [Date?] = []
    var date = adjustedStart

    while date <= today {
      let weekday = calendar.component(.weekday, from: date)
      if weekday == calendar.firstWeekday && !currentWeek.isEmpty {
        weeks.append(currentWeek)
        currentWeek = []
      }
      currentWeek.append(date)
      date = calendar.date(byAdding: .day, value: 1, to: date)!
    }

    if !currentWeek.isEmpty {
      while currentWeek.count < 7 {
        currentWeek.append(nil)
      }
      weeks.append(currentWeek)
    }

    return weeks
  }

  var body: some View {
    VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
      Text("ACTIVITY")
        .font(AppTheme.captionFont)
        .foregroundStyle(AppTheme.textSecondary)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 3) {
          ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
            VStack(spacing: 3) {
              ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                if let day {
                  dayCell(for: day)
                } else {
                  RoundedRectangle(cornerRadius: 2)
                    .fill(Color.clear)
                    .frame(width: 14, height: 14)
                }
              }
            }
          }
        }
        .padding(AppTheme.smallSpacing)
      }
      .background(AppTheme.surfaceLight.opacity(0.3))
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  private func dayCell(for date: Date) -> some View {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let isCheckedIn = checkedInDates.contains(components)
    let isFuture = date > .now

    return RoundedRectangle(cornerRadius: 2)
      .fill(
        isFuture
          ? Color.clear
          : isCheckedIn ? color : AppTheme.surfaceLight
      )
      .frame(width: 14, height: 14)
      .overlay(
        RoundedRectangle(cornerRadius: 2)
          .strokeBorder(
            isFuture ? AppTheme.surfaceLight.opacity(0.3) : .clear,
            lineWidth: 0.5
          )
      )
  }
}
