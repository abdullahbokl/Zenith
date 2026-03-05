import SwiftUI

extension Color {

  /// Initialise a `Color` from a hex string (e.g. `"#FF6B6B"` or `"FF6B6B"`).
  /// Returns a fallback purple if the string is invalid.
  init(hex: String) {
    let sanitised =
      hex
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "#", with: "")

    guard sanitised.count == 6,
      sanitised.allSatisfy({ $0.isHexDigit })
    else {
      self.init(red: 0.42, green: 0.39, blue: 1.0)  // fallback to accent
      return
    }

    var rgb: UInt64 = 0
    Scanner(string: sanitised).scanHexInt64(&rgb)

    let r = Double((rgb >> 16) & 0xFF) / 255
    let g = Double((rgb >> 8) & 0xFF) / 255
    let b = Double(rgb & 0xFF) / 255

    self.init(red: r, green: g, blue: b)
  }
}
