import SwiftUI
import SwiftData

struct TileCalcView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("defaultWastePercent") private var defaultWastePercent: Double = 10

    @State private var wallWidth = ""
    @State private var wallHeight = ""
    @State private var openings: [Opening] = []
    @State private var tileWidthMM = "600"
    @State private var tileHeightMM = "600"
    @State private var gapMM = "2"
    @State private var adhesiveKgPerM2: Double = 4.5
    @State private var tilePrice = ""
    @State private var wastePercent: Double = 10
    @State private var hasInitWaste = false
    @State private var showSave = false
    @FocusState private var focus: Field?
    enum Field { case w, h, tw, th, gap, price }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    private var grossArea: Double {
        let w = units.toMetric(Double(wallWidth) ?? 0)
        let h = units.toMetric(Double(wallHeight) ?? 0)
        return w * h
    }
    private var openingsArea: Double { openings.reduce(0) { $0 + $1.area } }

    private var result: TileResult {
        TileCalculator.compute(
            area: grossArea,
            openingsArea: openingsArea,
            tileWidthMM: Double(tileWidthMM) ?? 0,
            tileHeightMM: Double(tileHeightMM) ?? 0,
            gapMM: Double(gapMM) ?? 0,
            adhesiveKgPerM2: adhesiveKgPerM2,
            wastePercent: wastePercent
        )
    }
    private var isValid: Bool { result.tileCount > 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 12) {
                        Text("SURFACE").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 10) {
                            NeoField(label: "Width (\(units.lengthUnit))", text: $wallWidth).focused($focus, equals: .w)
                            NeoField(label: "Height (\(units.lengthUnit))", text: $wallHeight).focused($focus, equals: .h)
                        }
                    }
                }
                GlassCard { OpeningsEditor(openings: $openings, units: units) }
                GlassCard {
                    VStack(spacing: 12) {
                        Text("TILE").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 10) {
                            NeoField(label: "Width (mm)", text: $tileWidthMM).focused($focus, equals: .tw)
                            NeoField(label: "Height (mm)", text: $tileHeightMM).focused($focus, equals: .th)
                            NeoField(label: "Gap (mm)", text: $gapMM).focused($focus, equals: .gap)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Adhesive consumption").font(.caption).foregroundColor(.white.opacity(0.5))
                                Spacer()
                                Text(String(format: "%.1f kg/m²", adhesiveKgPerM2)).font(.subheadline.bold()).foregroundColor(.orange)
                            }
                            Slider(value: $adhesiveKgPerM2, in: 2...8, step: 0.5).tint(.orange)
                        }
                        NeoField(label: "Tile price / pcs (\(currencySymbol))", text: $tilePrice, icon: "dollarsign").focused($focus, equals: .price)
                    }
                }
                GlassCard { WastePercentField(value: $wastePercent) }
                if isValid {
                    let r = result
                    let price = Double(tilePrice) ?? 0
                    VStack(spacing: 10) {
                        ResultCard(icon: "square.grid.2x2", color: Color(hex: "00B4D8"), title: "Tiles",
                                   value: "\(r.tileCount) pcs")
                        ResultCard(icon: "drop.fill", color: Color(hex: "8D99AE"), title: "Adhesive",
                                   value: String(format: "%.1f kg (%d bags 25 kg)", r.adhesiveKg, r.adhesiveBags))
                        ResultCard(icon: "paintpalette", color: Color(hex: "BDB2FF"), title: "Grout",
                                   value: String(format: "%.1f kg", r.groutKg))
                        if price > 0 {
                            ResultCard(icon: "dollarsign.circle", color: .green, title: "Tile cost",
                                       value: Currency.format(Double(r.tileCount) * price, code: currencyCode), highlighted: true)
                        }
                        CTAButton(label: "Save to project", icon: "square.and.arrow.down") { showSave = true }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Tile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focus = nil } } }
        .onAppear { if !hasInitWaste { wastePercent = defaultWastePercent; hasInitWaste = true } }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .tile,
                suggestedTitle: "Tile \(tileWidthMM)×\(tileHeightMM) — \(result.tileCount) pcs",
                materialName: "Tile \(tileWidthMM)×\(tileHeightMM)mm",
                materialUnit: "pcs",
                quantity: Double(result.tileCount),
                unitPrice: Double(tilePrice) ?? 0,
                detailJSON: "{}",
                unitSystem: units
            )
        }
    }
}
