import SwiftUI

struct HomeView: View {
    let units: UnitSystem
    let currencyCode: String

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Calculators")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(CalculatorKind.allCases) { kind in
                                NavigationLink {
                                    destination(for: kind)
                                } label: {
                                    CalculatorTile(kind: kind)
                                }
                                .buttonStyle(.plain)
                            }
                            NavigationLink {
                                UnitConverterView()
                            } label: {
                                CalculatorTile(kind: nil, name: "Converter", icon: "arrow.triangle.2.circlepath", color: .cyan)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private func destination(for kind: CalculatorKind) -> some View {
        switch kind {
        case .area:      AreaCalcView()
        case .volume:    VolumeCalcView()
        case .wallpaper: WallpaperCalcView()
        case .concrete:  ConcreteCalcView()
        case .tile:      TileCalcView()
        case .paint:     PaintCalcView()
        case .drywall:   DrywallCalcView()
        case .laminate:  LaminateCalcView()
        case .screed:    ScreedCalcView()
        case .brick:     BrickCalcView()
        case .plaster:   PlasterCalcView()
        }
    }
}

private struct CalculatorTile: View {
    let kind: CalculatorKind?
    var name: String? = nil
    var icon: String? = nil
    var color: Color? = nil

    private var resolvedName: String { name ?? kind?.displayName ?? "" }
    private var resolvedIcon: String { icon ?? kind?.iconSF ?? "questionmark" }
    private var resolvedColor: Color { color ?? tileColor(for: kind) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                Circle().fill(resolvedColor.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: resolvedIcon).foregroundColor(resolvedColor).font(.title3)
            }
            Spacer(minLength: 0)
            Text(resolvedName).font(.subheadline.bold()).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 124)
        .padding(14)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.06), lineWidth: 0.5))
    }

    private func tileColor(for kind: CalculatorKind?) -> Color {
        switch kind {
        case .area: .cyan
        case .volume: .indigo
        case .wallpaper: .orange
        case .concrete: Color(hex: "6B7280")
        case .tile: Color(hex: "00B4D8")
        case .paint: Color(hex: "7B2FBE")
        case .drywall: Color(hex: "F8F9FA")
        case .laminate: Color(hex: "C9A96E")
        case .screed: Color(hex: "ADB5BD")
        case .brick: Color(hex: "B85C38")
        case .plaster: Color(hex: "F1FAEE")
        case .none: .orange
        }
    }
}
