import SwiftUI

struct WastePercentField: View {
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...30

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "scissors").font(.caption2).foregroundColor(.orange.opacity(0.7))
                Text("WASTE").font(.caption).foregroundColor(.white.opacity(0.5))
                Spacer()
                Text(String(format: "%.0f%%", value))
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundColor(.orange)
            }
            Slider(value: $value, in: range, step: 1).tint(.orange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.06), lineWidth: 0.5))
    }
}
