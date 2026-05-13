import SwiftUI

struct GlassBg: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        ZStack {
            Color(.systemBackground)
            TimelineView(.animation) { _ in
                Canvas { ctx, size in
                    let r1 = ctx.resolveSymbol(id: 0)!
                    let r2 = ctx.resolveSymbol(id: 1)!
                    let r3 = ctx.resolveSymbol(id: 2)!
                    ctx.draw(r1, in: CGRect(x: -60 + sin(phase) * 30, y: -100 + cos(phase * 1.3) * 40, width: size.width * 0.7, height: size.width * 0.7))
                    ctx.draw(r2, in: CGRect(x: size.width * 0.4 + cos(phase * 0.7) * 20, y: size.height * 0.2 + sin(phase * 0.8) * 30, width: size.width * 0.6, height: size.width * 0.6))
                    ctx.draw(r3, in: CGRect(x: size.width * 0.1 + sin(phase * 0.5) * 25, y: size.height * 0.5 + cos(phase) * 20, width: size.width * 0.5, height: size.width * 0.5))
                } symbols: {
                    Circle().fill(.orange.opacity(0.08)).tag(0)
                    Circle().fill(.cyan.opacity(0.06)).tag(1)
                    Circle().fill(.purple.opacity(0.07)).tag(2)
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
        }
        .ignoresSafeArea()
    }
}
