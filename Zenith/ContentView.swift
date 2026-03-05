import SwiftData
import SwiftUI

struct ContentView: View {

  @Environment(\.modelContext) private var modelContext
  @State private var viewModel: HabitViewModel?

  var body: some View {
    NavigationStack {
      Group {
        if let viewModel {
          DashboardView(viewModel: viewModel)
        } else {
          ProgressView()
            .tint(AppTheme.accent)
        }
      }
    }
    .preferredColorScheme(.dark)
    .onAppear {
      if viewModel == nil {
        let repository = SwiftDataHabitRepository(modelContext: modelContext)
        viewModel = HabitViewModel(repository: repository)
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Habit.self, inMemory: true)
}
