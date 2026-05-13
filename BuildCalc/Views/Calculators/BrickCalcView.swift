import SwiftUI
import SwiftData

struct BrickCalcView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"

    @State private var wallL = ""
    @State private var wallH = ""
    @State private var openings: [Opening] = []
    @State private var thickness: WallThickness = .one
    @State private var kind: BrickKind = .single
    @State private var pricePerBrick = ""
    @State private var showSave = false
    @FocusState private var focus: Field?
    enum Field { case l, h, price }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    private var result: BrickResult {
        BrickCalculator.compute(
            wallLengthM: units.toMetric(Double(wallL) ?? 0),
            wallHeightM: units.toMetric(Double(wallH) ?? 0),
            openingsArea: openings.reduce(0) { $0 + $1.area },
            thickness: thickness,
            kind: kind
        )
    }
    private var isValid: Bool { result.bricks > 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 12) {
                        Text("WALL DIMENSIONS").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 10) {
                            NeoField(label: "Length (\(units.lengthUnit))", text: $wallL).focused($focus, equals: .l)
                            NeoField(label: "Height (\(units.lengthUnit))", text: $wallH).focused($focus, equals: .h)
                        }
                    }
                }
                GlassCard { OpeningsEditor(openings: $openings, units: units) }
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("WALL THICKNESS").font(.caption).foregroundColor(.white.opacity(0.3))
                        CapsulePicker(items: WallThickness.allCases, selection: $thickness)
                    }
                }
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("BRICK TYPE").font(.caption).foregroundColor(.white.opacity(0.3))
                        CapsulePicker(items: BrickKind.allCases, selection: $kind)
                        NeoField(label: "Price / brick (\(currencySymbol))", text: $pricePerBrick, icon: "dollarsign").focused($focus, equals: .price)
                    }
                }
                if isValid {
                    let r = result
                    let pricePer = Double(pricePerBrick) ?? 0
                    VStack(spacing: 10) {
                        ResultCard(icon: "square.grid.3x3", color: Color(hex: "B85C38"), title: "Bricks",
                                   value: "\(r.bricks) pcs")
                        ResultCard(icon: "drop.fill", color: Color(hex: "ADB5BD"), title: "Mortar",
                                   value: String(format: "%.3f m³", r.mortarVolume))
                        ResultCard(icon: "cube", color: Color(hex: "ADB5BD"), title: "Cement",
                                   value: String(format: "%.0f kg", r.cementKg))
                        ResultCard(icon: "circle.grid.3x3.fill", color: Color(hex: "F4A261"), title: "Sand",
                                   value: String(format: "%.0f kg", r.sandKg))
                        if pricePer > 0 {
                            ResultCard(icon: "dollarsign.circle", color: .green, title: "Brick cost",
                                       value: Currency.format(Double(r.bricks) * pricePer, code: currencyCode), highlighted: true)
                        }
                        CTAButton(label: "Save to project", icon: "square.and.arrow.down") { showSave = true }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Brick")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focus = nil } } }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .brick,
                suggestedTitle: "Brick \(thickness.rawValue) — \(result.bricks) pcs",
                materialName: "\(kind.rawValue) brick",
                materialUnit: "pcs",
                quantity: Double(result.bricks),
                unitPrice: Double(pricePerBrick) ?? 0,
                detailJSON: "{}",
                unitSystem: units
            )
        }
    }
}
