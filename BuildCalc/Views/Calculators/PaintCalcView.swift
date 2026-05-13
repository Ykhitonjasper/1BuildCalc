import SwiftUI
import SwiftData

struct PaintCalcView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"

    @State private var wallWidth = ""
    @State private var wallHeight = ""
    @State private var openings: [Opening] = []
    @State private var coats: Int = 2
    @State private var paintConsumption: Double = 0.14
    @State private var paintPrice = ""
    @State private var includePrimer = true
    @State private var primerConsumption: Double = 0.15
    @State private var primerPrice = ""
    @State private var showSave = false
    @FocusState private var focus: Field?
    enum Field { case w, h, paintP, primerP }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    private var area: Double {
        let w = units.toMetric(Double(wallWidth) ?? 0)
        let h = units.toMetric(Double(wallHeight) ?? 0)
        return max(0, w * h - openings.reduce(0) { $0 + $1.area })
    }
    private var paintL: Double { area * paintConsumption * Double(coats) }
    private var primerL: Double { includePrimer ? area * primerConsumption : 0 }
    private var isValid: Bool { area > 0 }

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
                        Text("PAINT").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        Stepper("Coats: \(coats)", value: $coats, in: 1...4).foregroundColor(.white)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Consumption").font(.caption).foregroundColor(.white.opacity(0.5))
                                Spacer()
                                Text(String(format: "%.2f L/m²", paintConsumption)).font(.subheadline.bold()).foregroundColor(.orange)
                            }
                            Slider(value: $paintConsumption, in: 0.08...0.30, step: 0.01).tint(.orange)
                        }
                        NeoField(label: "Price / L (\(currencySymbol))", text: $paintPrice, icon: "dollarsign").focused($focus, equals: .paintP)
                    }
                }
                GlassCard {
                    VStack(spacing: 12) {
                        Toggle("Include primer", isOn: $includePrimer)
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                            .foregroundColor(.white)
                        if includePrimer {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Primer consumption").font(.caption).foregroundColor(.white.opacity(0.5))
                                    Spacer()
                                    Text(String(format: "%.2f L/m²", primerConsumption)).font(.subheadline.bold()).foregroundColor(.cyan)
                                }
                                Slider(value: $primerConsumption, in: 0.08...0.25, step: 0.01).tint(.cyan)
                            }
                            NeoField(label: "Primer price / L (\(currencySymbol))", text: $primerPrice, icon: "dollarsign").focused($focus, equals: .primerP)
                        }
                    }
                }
                if isValid {
                    let paintCost = paintL * (Double(paintPrice) ?? 0)
                    let primerCost = primerL * (Double(primerPrice) ?? 0)
                    let totalCost = paintCost + primerCost
                    VStack(spacing: 10) {
                        ResultCard(icon: "square", color: .cyan, title: "Net area",
                                   value: String(format: "%.2f m²", area))
                        ResultCard(icon: "paintbrush", color: Color(hex: "7B2FBE"), title: "Paint",
                                   value: String(format: "%.2f L (%d coats)", paintL, coats))
                        if includePrimer {
                            ResultCard(icon: "paintbrush.pointed", color: Color(hex: "9D4EDD"), title: "Primer",
                                       value: String(format: "%.2f L", primerL))
                        }
                        if totalCost > 0 {
                            ResultCard(icon: "dollarsign.circle", color: .green, title: "Total cost",
                                       value: Currency.format(totalCost, code: currencyCode), highlighted: true)
                        }
                        CTAButton(label: "Save to project", icon: "square.and.arrow.down") { showSave = true }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Paint")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focus = nil } } }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .paint,
                suggestedTitle: "Paint \(coats) coats — \(String(format: "%.2f L", paintL))",
                materialName: "Wall paint",
                materialUnit: "L",
                quantity: paintL,
                unitPrice: Double(paintPrice) ?? 0,
                detailJSON: "{}",
                unitSystem: units
            )
        }
    }
}
