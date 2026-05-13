import SwiftUI

struct NeoField: View {
    let label: String
    @Binding var text: String
    var icon: String?
    var keyboard: UIKeyboardType = .decimalPad

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 4) {
                if let i = icon {
                    Image(systemName: i).font(.caption2).foregroundColor(.orange.opacity(0.7))
                }
                Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            }
            TextField("0", text: $text)
                .keyboardType(keyboard)
                .font(.title3.monospacedDigit())
                .foregroundColor(.white)
                .padding(.vertical, 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.06), lineWidth: 0.5))
    }
}
