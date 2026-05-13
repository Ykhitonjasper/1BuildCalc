import SwiftUI

struct CapsulePicker<T: Identifiable & Hashable>: View where T: RawRepresentable, T.RawValue == String {
    let items: [T]
    @Binding var selection: T
    var iconFor: ((T) -> String)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(items) { item in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selection = item
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if let fn = iconFor { Image(systemName: fn(item)).font(.caption2) }
                            Text(item.rawValue).font(.caption.bold())
                        }
                        .foregroundColor(selection == item ? .black : .white.opacity(0.6))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selection == item ? Color.white : Color.white.opacity(0.06))
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
