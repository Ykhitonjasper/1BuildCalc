import SwiftUI

struct CTAButton: View {
    let label: String
    let icon: String
    let action: () -> Void
    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).symbolEffect(.bounce, value: pulse)
                Text(label)
            }
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(LinearGradient(colors: [.orange, Color(hex: "FF6B35")], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(14)
        }
        .onAppear { pulse = true }
    }
}
