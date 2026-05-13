import SwiftUI
import SwiftData

struct WallpaperCalcView: View {
    @EnvironmentObject var vm: WallpaperCalcVM
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"

    @FocusState private var focus: Field?
    @State private var showSave = false
    enum Field { case l, w, h, p }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    private var roomLengthM: Double { units.toMetric(Double(vm.roomLength) ?? 0) }
    private var roomWidthM: Double { units.toMetric(Double(vm.roomWidth) ?? 0) }
    private var roomHeightM: Double { units.toMetric(Double(vm.roomHeight) ?? 0) }
    private var rollLenM: Double { units.toMetric(Double(vm.rollLength) ?? 10) }
    private var rollWidM: Double { units.toMetric(Double(vm.rollWidth) ?? 1.06) }
    private var perimeterM: Double { 2 * (roomLengthM + roomWidthM) }
    private var grossWallArea: Double { perimeterM * roomHeightM }
    private var netWallArea: Double { max(0, grossWallArea - vm.openingsAreaMetric) }
    private var stripsPerRoll: Int { max(1, Int(rollLenM / max(roomHeightM, 0.01))) }
    private var stripsNeeded: Int { rollWidM > 0 ? Int(ceil(perimeterM / rollWidM)) : 0 }
    private var rolls: Int { max(0, Int(ceil(Double(stripsNeeded) / Double(stripsPerRoll) * vm.selectedPattern.waste))) }
    private var totalCost: Double { Double(rolls) * (Double(vm.pricePerRoll) ?? 0) }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 12) {
                        Text("ROOM DIMENSIONS").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 10) {
                            NeoField(label: "Length (\(units.lengthUnit))", text: $vm.roomLength).focused($focus, equals: .l)
                            NeoField(label: "Width (\(units.lengthUnit))", text: $vm.roomWidth).focused($focus, equals: .w)
                        }
                        NeoField(label: "Height (\(units.lengthUnit))", text: $vm.roomHeight).focused($focus, equals: .h)
                    }
                }
                GlassCard { OpeningsEditor(openings: $vm.openings, units: units) }
                GlassCard {
                    VStack(spacing: 12) {
                        Text("ROLL PARAMETERS").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 10) {
                            NeoField(label: "Length (\(units.lengthUnit))", text: $vm.rollLength)
                            NeoField(label: "Width (\(units.lengthUnit))", text: $vm.rollWidth)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PATTERN TYPE").font(.caption).foregroundColor(.white.opacity(0.3))
                            CapsulePicker(items: WallpaperCalcVM.Pattern.allCases, selection: $vm.selectedPattern)
                        }
                        NeoField(label: "Price / roll (\(currencySymbol))", text: $vm.pricePerRoll, icon: "dollarsign").focused($focus, equals: .p)
                    }
                }
                if vm.isValid {
                    VStack(spacing: 10) {
                        ResultCard(icon: "square", color: .cyan, title: "Net wall area",
                                   value: "\(String(format: "%.1f", units.areaFromMetric(netWallArea))) \(units.areaUnit)")
                        if !vm.openings.isEmpty {
                            ResultCard(icon: "rectangle.dashed", color: .gray, title: "Subtracted openings",
                                       value: "\(String(format: "%.2f", units.areaFromMetric(vm.openingsAreaMetric))) \(units.areaUnit)")
                        }
                        ResultCard(icon: "doc.richtext", color: .orange, title: "Rolls needed",
                                   value: "\(rolls) pcs")
                        if totalCost > 0 {
                            ResultCard(icon: "dollarsign.circle", color: .green, title: "Cost",
                                       value: Currency.format(totalCost, code: currencyCode), highlighted: true)
                        }
                        CTAButton(label: "Save to project", icon: "square.and.arrow.down") {
                            showSave = true
                        }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Wallpaper")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if vm.isValid {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { withAnimation { vm.reset() } } label: { Text("Reset").font(.subheadline) }
                }
            }
            ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focus = nil } }
        }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .wallpaper,
                suggestedTitle: "Wallpaper — \(String(format: "%.1f", units.areaFromMetric(netWallArea)))\(units.areaUnit)",
                materialName: "Wallpaper",
                materialUnit: "roll",
                quantity: Double(rolls),
                unitPrice: Double(vm.pricePerRoll) ?? 0,
                detailJSON: "{}",
                unitSystem: units
            )
        }
    }
}
