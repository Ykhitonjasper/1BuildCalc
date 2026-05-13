import SwiftUI
import SwiftData

struct ConcreteCalcView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"

    @State private var length = ""
    @State private var width = ""
    @State private var depth = ""
    @State private var pricePerM3 = ""
    @State private var grade: ConcreteGrade = .m200
    @State private var rebar: RebarDiameter = .d10
    @State private var cellSizeCm: Double = 20
    @State private var layers: Int = 1
    @State private var showSave = false
    @FocusState private var focus: Field?
    enum Field { case l, w, d, p }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    private var result: ConcreteResult {
        ConcreteCalculator.compute(
            length: units.toMetric(Double(length) ?? 0),
            width: units.toMetric(Double(width) ?? 0),
            depth: units.toMetric(Double(depth) ?? 0),
            grade: grade,
            rebarD: rebar,
            cellSize: cellSizeCm / 100,
            layers: layers
        )
    }
    private var isValid: Bool { result.volume > 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 12) {
                        Text("FOUNDATION DIMENSIONS").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        NeoField(label: "Length (\(units.lengthUnit))", text: $length).focused($focus, equals: .l)
                        HStack(spacing: 10) {
                            NeoField(label: "Width (\(units.lengthUnit))", text: $width).focused($focus, equals: .w)
                            NeoField(label: "Depth (\(units.lengthUnit))", text: $depth).focused($focus, equals: .d)
                        }
                        NeoField(label: "Price / m³ (\(currencySymbol))", text: $pricePerM3, icon: "dollarsign").focused($focus, equals: .p)
                    }
                }
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CONCRETE GRADE").font(.caption).foregroundColor(.white.opacity(0.3))
                        CapsulePicker(items: ConcreteGrade.allCases, selection: $grade)
                    }
                }
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("REINFORCEMENT").font(.caption).foregroundColor(.white.opacity(0.3))
                        CapsulePicker(items: RebarDiameter.allCases, selection: $rebar)
                        HStack {
                            Text("Mesh cell").font(.caption).foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text(String(format: "%.0f cm", cellSizeCm))
                                .font(.subheadline.bold().monospacedDigit()).foregroundColor(.orange)
                        }
                        Slider(value: $cellSizeCm, in: 10...40, step: 5).tint(.orange)
                        Stepper("Layers: \(layers)", value: $layers, in: 1...3).foregroundColor(.white)
                    }
                }
                if isValid {
                    let r = result
                    let priceM3 = Double(pricePerM3) ?? 0
                    VStack(spacing: 10) {
                        ResultCard(icon: "cube.fill", color: .cyan, title: "Concrete volume",
                                   value: String(format: "%.3f m³", r.volume))
                        ResultCard(icon: "cube", color: Color(hex: "ADB5BD"), title: "Cement",
                                   value: String(format: "%.0f kg (≈ %.0f bags 50 kg)", r.cement, ceil(r.cement/50)))
                        ResultCard(icon: "circle.grid.3x3.fill", color: Color(hex: "F4A261"), title: "Sand",
                                   value: String(format: "%.0f kg", r.sand))
                        ResultCard(icon: "circle.dotted", color: Color(hex: "A0A0A0"), title: "Gravel",
                                   value: String(format: "%.0f kg", r.gravel))
                        ResultCard(icon: "drop.fill", color: .blue, title: "Water",
                                   value: String(format: "%.0f L", r.water))
                        if rebar != .none {
                            ResultCard(icon: "line.diagonal", color: Color(hex: "FF6B35"), title: "Rebar \(rebar.displayName)",
                                       value: String(format: "%.1f m (%.1f kg)", r.rebarLength, r.rebarMass))
                        }
                        if priceM3 > 0 {
                            ResultCard(icon: "dollarsign.circle", color: .green, title: "Cost",
                                       value: Currency.format(r.volume * priceM3, code: currencyCode), highlighted: true)
                        }
                        CTAButton(label: "Save to project", icon: "square.and.arrow.down") { showSave = true }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Concrete")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focus = nil } } }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .concrete,
                suggestedTitle: "Concrete \(grade.displayName) — \(String(format: "%.2f", result.volume))m³",
                materialName: "Concrete \(grade.displayName)",
                materialUnit: "m³",
                quantity: result.volume,
                unitPrice: Double(pricePerM3) ?? 0,
                detailJSON: "{}",
                unitSystem: units
            )
        }
    }
}
