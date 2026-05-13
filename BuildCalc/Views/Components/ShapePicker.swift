import SwiftUI

struct ShapePicker: View {
    @Binding var selection: RoomShape

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RoomShape.allCases) { shape in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selection = shape
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: shape.iconSF).font(.subheadline)
                            Text(shape.rawValue).font(.caption2)
                        }
                        .frame(width: 64, height: 64)
                        .foregroundColor(selection == shape ? .black : .white.opacity(0.6))
                        .background(selection == shape ? Color.white : Color.white.opacity(0.06))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
