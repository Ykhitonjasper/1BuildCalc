import SwiftUI

struct ResultCard: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    var highlighted = false
    @State private var appear = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
                .scaleEffect(appear ? 1 : 0.5)
                .opacity(appear ? 1 : 0)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundColor(.white.opacity(0.4))
                Text(value).font(.title2.bold().monospacedDigit()).foregroundColor(highlighted ? .green : .white)
            }
            Spacer()
        }
        .padding(16)
        .background((highlighted ? Color.green : color).opacity(0.08))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke((highlighted ? Color.green : color).opacity(0.15), lineWidth: 0.5))
        .offset(y: appear ? 0 : 20)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.05)) {
                appear = true
            }
        }
    }
}
