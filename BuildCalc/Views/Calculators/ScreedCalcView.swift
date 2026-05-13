import SwiftUI
import SwiftData

struct ScreedCalcView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"

    @State private var roomL = ""
    @State private var roomW = ""
    @State private var thicknessMM: Double = 50
    @State private var mixType: MixType = .cementSand
    @State private var bagWeight: Double = 25
    @State private var pricePerBag = ""
    @State private var showSave = false
    @FocusState private var focus: Field?
    enum Field { case l, w, p }

    enum MixType: String, CaseIterable, Identifiable {
        case cementSand = "Cement-sand"
        case selfLevel = "Self-leveling"
        case dry = "Dry screed"
        var id: String { rawValue }
        var densityKgPerM3: Double {
            switch self {
            case .cementSand: 1800
            case .selfLevel: 1500
            case .dry: 600
            }
        }
    }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    private var area: Double {
        units.toMetric(Double(roomL) ?? 0) * units.toMetric(Double(roomW) ?? 0)
    }
    private var volume: Double { area * (thicknessMM / 1000.0) }
    private var massKg: Double { volume * mixType.densityKgPerM3 }
    private var bags: Int { bagWeight > 0 ? Int(ceil(massKg / bagWeight)) : 0 }
    private var isValid: Bool { volume > 0 }

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
                    VStack(alignment: .leading, spacing: 10) {
                        Text("LAYER").font(.caption).foregroundColor(.white.opacity(0.3))
                        HStack {
                            Text("Thickness").font(.caption).foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text(String(format: "%.0f mm", thicknessMM)).font(.subheadline.bold().monospacedDigit()).foregroundColor(.orange)
                        }
                        Slider(value: $thicknessMM, in: 10...150, step: 5).tint(.orange)
                        CapsulePicker(items: MixType.allCases, selection: $mixType)
                    }
                }
                GlassCard {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Bag weight").font(.caption).foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text(String(format: "%.0f kg", bagWeight)).font(.subheadline.bold()).foregroundColor(.cyan)
                        }
                        Slider(value: $bagWeight, in: 10...50, step: 5).tint(.cyan)
                        NeoField(label: "Price / bag (\(currencySymbol))", text: $pricePerBag, icon: "dollarsign").focused($focus, equals: .p)
                    }
                }
                if isValid {
                    let pricePerBagV = Double(pricePerBag) ?? 0
                    VStack(spacing: 10) {
                        ResultCard(icon: "cube.fill", color: .cyan, title: "Volume",
                                   value: String(format: "%.3f m³", volume))
                        ResultCard(icon: "square.fill", color: Color(hex: "ADB5BD"), title: mixType.rawValue,
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
        .navigationTitle("Screed")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focus = nil } } }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .screed,
                suggestedTitle: "\(mixType.rawValue) — \(bags) bags",
                materialName: mixType.rawValue,
                materialUnit: "bag",
                quantity: Double(bags),
                unitPrice: Double(pricePerBag) ?? 0,
                detailJSON: "{}",
                unitSystem: units
            )
        }
    }
}
