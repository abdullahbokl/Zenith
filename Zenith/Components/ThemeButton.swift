import SwiftUI

/// Gradient action button with press animation and haptic feedback.
struct ThemeButton: View {

  let title: String
  let icon: String?
  let action: () -> Void

  init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
    self.title = title
    self.icon = icon
    self.action = action
  }

  var body: some View {
    Button(action: {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      action()
    }) {
      HStack(spacing: AppTheme.smallSpacing) {
        if let icon {
          Image(systemName: icon)
            .font(.system(size: 16, weight: .semibold))
        }
        Text(title)
          .font(AppTheme.headlineFont)
      }
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(AppTheme.accentGradient)
      .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
    .buttonStyle(ScaleButtonStyle())
  }
}

#Preview {
  VStack(spacing: 16) {
    ThemeButton("Save Habit", icon: "checkmark.circle.fill") {}
    ThemeButton("Delete", icon: "trash.fill") {}
  }
  .padding()
  .background(AppTheme.background)
}
