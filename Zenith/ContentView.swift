import SwiftData
import SwiftUI

struct ContentView: View {

  @Environment(\.modelContext) private var modelContext

  var body: some View {
    NavigationStack {
      DashboardView(viewModel: HabitViewModel(modelContext: modelContext))
    }
    .preferredColorScheme(.dark)
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Habit.self, inMemory: true)
}
