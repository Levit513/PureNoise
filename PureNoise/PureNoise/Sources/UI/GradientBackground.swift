import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.06, green: 0.07, blue: 0.14),
                Color(red: 0.05, green: 0.08, blue: 0.20),
                Color(red: 0.02, green: 0.02, blue: 0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            RadialGradient(
                colors: [
                    Color(red: 0.40, green: 0.22, blue: 0.75, opacity: 0.35),
                    .clear
                ],
                center: .top,
                startRadius: 40,
                endRadius: 420
            )
        }
        .overlay {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.55, blue: 0.95, opacity: 0.22),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 60,
                endRadius: 480
            )
        }
    }
}
