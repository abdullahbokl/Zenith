import SwiftUI

/// Animated circular progress ring.
struct CircularProgressView: View {

    let progress: Double
    let lineWidth: CGFloat
    let gradient: LinearGradient
    let size: CGFloat

    init(
        progress: Double,
        lineWidth: CGFloat = 4,
        gradient: LinearGradient = AppTheme.accentGradient,
        size: CGFloat = 44
    ) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.gradient = gradient
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.surfaceLight.opacity(0.5), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.6), value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 20) {
        CircularProgressView(progress: 0.25, size: 60)
        CircularProgressView(progress: 0.5, size: 60)
        CircularProgressView(progress: 0.75, size: 60)
        CircularProgressView(progress: 1.0, size: 60)
    }
    .padding()
    .background(AppTheme.background)
}
