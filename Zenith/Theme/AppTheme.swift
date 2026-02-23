import SwiftUI

/// Centralised design tokens for the Zenith app.
enum AppTheme {

  // MARK: - Colours

  static let accent = Color(hex: "#6C63FF")
  static let accentLight = Color(hex: "#A29BFE")
  static let background = Color(hex: "#0F0F1A")
  static let surface = Color(hex: "#1A1A2E")
  static let surfaceLight = Color(hex: "#25253D")
  static let textPrimary = Color.white
  static let textSecondary = Color.white.opacity(0.6)
  static let success = Color(hex: "#00C897")
  static let danger = Color(hex: "#FF6B6B")

  static let habitColors: [String] = [
    "#FF6B6B", "#FF8E72", "#FFC75F",
    "#00C897", "#00B4D8", "#6C63FF",
    "#A29BFE", "#E056A0", "#FF85A1",
    "#48BFE3", "#5390D9", "#7400B8",
  ]

  static let habitIcons: [String] = [
    "figure.run", "book.fill", "drop.fill",
    "moon.fill", "heart.fill", "brain.head.profile",
    "dumbbell.fill", "cup.and.saucer.fill", "leaf.fill",
    "paintbrush.fill", "music.note", "pencil.and.outline",
    "alarm.fill", "bicycle", "fork.knife",
    "pills.fill", "bed.double.fill", "sun.max.fill",
  ]

  // MARK: - Typography

  static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
  static let headlineFont = Font.system(size: 18, weight: .semibold, design: .rounded)
  static let bodyFont = Font.system(size: 15, weight: .regular, design: .rounded)
  static let captionFont = Font.system(size: 12, weight: .medium, design: .rounded)

  // MARK: - Layout

  static let cornerRadius: CGFloat = 20
  static let cardCornerRadius: CGFloat = 16
  static let spacing: CGFloat = 16
  static let smallSpacing: CGFloat = 8
  static let iconSize: CGFloat = 44

  // MARK: - Gradients

  static let accentGradient = LinearGradient(
    colors: [accent, accentLight],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  static let cardGradient = LinearGradient(
    colors: [surface, surfaceLight],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
}
