import SwiftUI
import SwiftData

struct LaminateCalcView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"

    @State private var roomL = ""
    @State private var roomW = ""
    @State private var boardL = "1380"
    @State private var boardW = "193"
    @State private var boardsPerPack: Int = 8
    @State private var layout: LaminateLayout = .parallel
    @State private var extraWaste: Double = 0
    @State private var pricePerPack = ""
    @State private var showSave = false
    @FocusState private var focus: Field?
    enum Field { case l, w, bl, bw, price }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    private var result: LaminateResult {
        LaminateCalculator.compute(
            roomLengthM: units.toMetric(Double(roomL) ?? 0),
            roomWidthM: units.toMetric(Double(roomW) ?? 0),
            boardLengthMM: Double(boardL) ?? 0,
            boardWidthMM: Double(boardW) ?? 0,
            boardsPerPack: boardsPerPack,
            layout: layout,
            extraWastePercent: extraWaste
        )
    }
    private var isValid: Bool { result.boards > 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 12) {
                        Text("ROOM").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 10) {
                            NeoField(label: "Length (\(units.lengthUnit))", text: $roomL).focused($focus, equals: .l)
                            NeoField(label: "Width (\(units.lengthUnit))", text: $roomW).focused($focus, equals: .w)
                        }
                    }
                }
                GlassCard {
                    VStack(spacing: 12) {
                        Text("BOARD").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 10) {
                            NeoField(label: "Length (mm)", text: $boardL).focused($focus, equals: .bl)
                            NeoField(label: "Width (mm)", text: $boardW).focused($focus, equals: .bw)
                        }
                        Stepper("Boards / pack: \(boardsPerPack)", value: $boardsPerPack, in: 1...20).foregroundColor(.white)
                        NeoField(label: "Price / pack (\(currencySymbol))", text: $pricePerPack, icon: "dollarsign").focused($focus, equals: .price)
                    }
                }
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("LAYOUT").font(.caption).foregroundColor(.white.opacity(0.3))
                        CapsulePicker(items: LaminateLayout.allCases, selection: $layout)
                        Text("Built-in waste: \(Int(layout.defaultWastePercent))%. Slider below adds extra.")
                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                    }
                }
                GlassCard { WastePercentField(value: $extraWaste, range: 0...20) }
                if isValid {
                    let r = result
                    let packPrice = Double(pricePerPack) ?? 0
                    VStack(spacing: 10) {
                        ResultCard(icon: "square", color: .cyan, title: "Floor area",
                                   value: String(format: "%.2f m²", r.floorArea))
                        ResultCard(icon: "square.stack", color: Color(hex: "C9A96E"), title: "Boards",
                                   value: "\(r.boards) pcs (\(r.packs) packs)")
                        ResultCard(icon: "rectangle.split.3x1", color: Color(hex: "FFD6A5"), title: "Underlay",
                                   value: String(format: "%.2f m²", r.underlayArea))
                        if packPrice > 0 {
                            ResultCard(icon: "dollarsign.circle", color: .green, title: "Pack cost",
                                       value: Currency.format(Double(r.packs) * packPrice, code: currencyCode), highlighted: true)
                        }
                        CTAButton(label: "Save to project", icon: "square.and.arrow.down") { showSave = true }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Laminate")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focus = nil } } }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .laminate,
                suggestedTitle: "Laminate \(layout.rawValue) — \(result.packs) packs",
                materialName: "Laminate",
                materialUnit: "pack",
                quantity: Double(result.packs),
                unitPrice: Double(pricePerPack) ?? 0,
                detailJSON: "{}",
                unitSystem: units
            )
        }
    }
}
