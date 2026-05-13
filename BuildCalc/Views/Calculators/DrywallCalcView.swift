import SwiftUI
import SwiftData

struct DrywallCalcView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("defaultWastePercent") private var defaultWastePercent: Double = 10

    @State private var wallWidth = ""
    @State private var wallHeight = ""
    @State private var openings: [Opening] = []
    @State private var sheetW: Double = 1.2
    @State private var sheetH: Double = 2.5
    @State private var layers: Int = 1
    @State private var waste: Double = 10
    @State private var sheetPrice = ""
    @State private var hasInitWaste = false
    @State private var showSave = false
    @FocusState private var focus: Field?
    enum Field { case w, h, price }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    private var widthM: Double { units.toMetric(Double(wallWidth) ?? 0) }
    private var heightM: Double { units.toMetric(Double(wallHeight) ?? 0) }
    private var perimeterM: Double { 2 * (widthM + heightM) }
    private var openingsArea: Double { openings.reduce(0) { $0 + $1.area } }

    private var result: DrywallResult {
        DrywallCalculator.compute(
            area: widthM * heightM,
            openingsArea: openingsArea,
            sheetWidthM: sheetW,
            sheetHeightM: sheetH,
            layers: layers,
            wastePercent: waste,
            perimeterM: perimeterM
        )
    }
    private var isValid: Bool { result.sheets > 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 12) {
                        Text("WALL DIMENSIONS").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 10) {
                            NeoField(label: "Width (\(units.lengthUnit))", text: $wallWidth).focused($focus, equals: .w)
                            NeoField(label: "Height (\(units.lengthUnit))", text: $wallHeight).focused($focus, equals: .h)
                        }
                    }
                }
                GlassCard { OpeningsEditor(openings: $openings, units: units) }
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SHEET").font(.caption).foregroundColor(.white.opacity(0.3))
                        HStack {
                            Picker("Width", selection: $sheetW) {
                                Text("1.2 m").tag(1.2)
                                Text("1.25 m").tag(1.25)
                            }.tint(.orange)
                            Picker("Height", selection: $sheetH) {
                                Text("2.5 m").tag(2.5)
                                Text("3.0 m").tag(3.0)
                            }.tint(.orange)
                        }
                        Stepper("Layers: \(layers)", value: $layers, in: 1...2).foregroundColor(.white)
                        NeoField(label: "Sheet price (\(currencySymbol))", text: $sheetPrice, icon: "dollarsign").focused($focus, equals: .price)
                    }
                }
                GlassCard { WastePercentField(value: $waste) }
                if isValid {
                    let r = result
                    let pricePerSheet = Double(sheetPrice) ?? 0
                    VStack(spacing: 10) {
                        ResultCard(icon: "rectangle.portrait", color: Color(hex: "F8F9FA"), title: "Drywall sheets",
                                   value: "\(r.sheets) pcs")
                        ResultCard(icon: "rectangle.stack", color: Color(hex: "ADB5BD"), title: "Profile UD 27",
                                   value: String(format: "%.1f m", r.udProfileMeters))
                        ResultCard(icon: "rectangle.stack.fill", color: Color(hex: "868E96"), title: "Profile CD 60",
                                   value: String(format: "%.1f m", r.cdProfileMeters))
                        ResultCard(icon: "screwdriver", color: Color(hex: "495057"), title: "Screws",
                                   value: "\(r.screws) pcs")
                        ResultCard(icon: "paintpalette", color: Color(hex: "E9ECEF"), title: "Joint putty",
                                   value: String(format: "%.1f kg", r.puttyKg))
                        ResultCard(icon: "ruler", color: Color(hex: "DEE2E6"), title: "Joint tape",
                                   value: String(format: "%.1f m", r.jointTapeMeters))
                        if pricePerSheet > 0 {
                            ResultCard(icon: "dollarsign.circle", color: .green, title: "Sheet cost",
                                       value: Currency.format(Double(r.sheets) * pricePerSheet, code: currencyCode), highlighted: true)
                        }
                        CTAButton(label: "Save to project", icon: "square.and.arrow.down") { showSave = true }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Drywall")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focus = nil } } }
        .onAppear { if !hasInitWaste { waste = defaultWastePercent; hasInitWaste = true } }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .drywall,
                suggestedTitle: "Drywall \(layers)L — \(result.sheets) sheets",
                materialName: "Drywall 12.5 mm",
                materialUnit: "pcs",
                quantity: Double(result.sheets),
                unitPrice: Double(sheetPrice) ?? 0,
                detailJSON: "{}",
                unitSystem: units
            )
        }
    }
}
