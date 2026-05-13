import SwiftUI

struct MatChip: View {
    let name: String
    let icon: String
    let color: Color
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.subheadline)
                Text(name).font(.caption2).lineLimit(1).minimumScaleFactor(0.7)
            }
            .foregroundColor(selected ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? color.opacity(0.25) : .white.opacity(0.04))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? color.opacity(0.5) : .white.opacity(0.05), lineWidth: 1))
        }
    }
}
