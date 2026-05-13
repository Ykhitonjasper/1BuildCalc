import SwiftUI

/// Dimension input that accepts both decimal and imperial fraction notation
/// (1' 6 3/4", 6 1/2", 1.5 m, 150 cm, 1500 mm). The bound string keeps the
/// raw user input; consumers parse via ImperialFraction when computing.
struct DimensionField: View {
    let label: String
    @Binding var text: String
    var icon: String?
    var system: UnitSystem
    @State private var parsedHint: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 4) {
                if let i = icon {
                    Image(systemName: i).font(.caption2).foregroundColor(.orange.opacity(0.7))
                }
                Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
                Spacer()
                if !parsedHint.isEmpty {
                    Text(parsedHint).font(.caption2).foregroundColor(.orange.opacity(0.6))
                }
            }
            TextField(placeholder, text: $text)
                .keyboardType(.numbersAndPunctuation)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .font(.title3.monospacedDigit())
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .onChange(of: text) { _, new in
                    parsedHint = computeHint(new)
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.06), lineWidth: 0.5))
    }

    private var placeholder: String {
        system == .metric ? "0 m" : "0' 0\""
    }

    private func computeHint(_ raw: String) -> String {
        guard !raw.isEmpty,
              let m = ImperialFraction.meters(raw, defaultUnit: system) else { return "" }
        if system == .metric {
            if raw.contains("'") || raw.contains("\"") {
                return String(format: "= %.3f m", m)
            }
            return ""
        }
        let ft = m * 3.281
        if raw.contains("'") || raw.contains("\"") || raw.contains("/") || raw.contains(" ") {
            return ""
        }
        return String(format: "= %.2f ft", ft)
    }
}
