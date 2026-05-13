import SwiftUI
import SwiftData

struct PlasterCalcView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"

    @State private var wallW = ""
    @State private var wallH = ""
    @State private var openings: [Opening] = []
    @State private var thicknessMM: Double = 15
    @State private var mix: MixType = .gypsum
    @State private var bagWeight: Double = 30
    @State private var pricePerBag = ""
    @State private var showSave = false
    @FocusState private var focus: Field?
    enum Field { case w, h, p }

    enum MixType: String, CaseIterable, Identifiable {
        case gypsum = "Gypsum"
        case cement = "Cement"
        var id: String { rawValue }
        /// kg per m² per mm of thickness.
        var kgPerM2PerMm: Double {
            switch self {
            case .gypsum: 0.85
            case .cement: 1.6
            }
        }
    }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    private var area: Double {
        let w = units.toMetric(Double(wallW) ?? 0)
        let h = units.toMetric(Double(wallH) ?? 0)
        return max(0, w * h - openings.reduce(0) { $0 + $1.area })
    }
    private var massKg: Double { area * mix.kgPerM2PerMm * thicknessMM }
    private var bags: Int { bagWeight > 0 ? Int(ceil(massKg / bagWeight)) : 0 }
    private var isValid: Bool { area > 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 12) {
                        Text("SURFACE").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 10) {
                            NeoField(label: "Width (\(units.lengthUnit))", text: $wallW).focused($focus, equals: .w)
                            NeoField(label: "Height (\(units.lengthUnit))", text: $wallH).focused($focus, equals: .h)
                        }
                    }
                }
                GlassCard { OpeningsEditor(openings: $openings, units: units) }
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("MIX & THICKNESS").font(.caption).foregroundColor(.white.opacity(0.3))
                        CapsulePicker(items: MixType.allCases, selection: $mix)
                        HStack {
                            Text("Layer thickness").font(.caption).foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text(String(format: "%.0f mm", thicknessMM)).font(.subheadline.bold().monospacedDigit()).foregroundColor(.orange)
                        }
                        Slider(value: $thicknessMM, in: 3...40, step: 1).tint(.orange)
                    }
                }
                GlassCard {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Bag weight").font(.caption).foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text(String(format: "%.0f kg", bagWeight)).font(.subheadline.bold()).foregroundColor(.cyan)
                        }
                        Slider(value: $bagWeight, in: 10...40, step: 5).tint(.cyan)
                        NeoField(label: "Price / bag (\(currencySymbol))", text: $pricePerBag, icon: "dollarsign").focused($focus, equals: .p)
                    }
                }
                if isValid {
                    let pricePerBagV = Double(pricePerBag) ?? 0
                    VStack(spacing: 10) {
                        ResultCard(icon: "square", color: .cyan, title: "Net area",
                                   value: String(format: "%.2f m²", area))
                        ResultCard(icon: "paintpalette.fill", color: Color(hex: "F1FAEE"), title: "\(mix.rawValue) plaster",
                                   value: String(format: "%.0f kg (%d bags)", massKg, bags))
                        if pricePerBagV > 0 {
                            ResultCard(icon: "dollarsign.circle", color: .green, title: "Cost",
                                       value: Currency.format(Double(bags) * pricePerBagV, code: currencyCode), highlighted: true)
                        }
                        CTAButton(label: "Save to project", icon: "square.and.arrow.down") { showSave = true }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Plaster")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focus = nil } } }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .plaster,
                suggestedTitle: "\(mix.rawValue) plaster — \(bags) bags",
                materialName: "\(mix.rawValue) plaster",
                materialUnit: "bag",
                quantity: Double(bags),
                unitPrice: Double(pricePerBag) ?? 0,
                detailJSON: "{}",
                unitSystem: units
            )
        }
    }
}
