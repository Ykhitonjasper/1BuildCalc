import SwiftUI
import SwiftData

struct AreaCalcView: View {
    @EnvironmentObject var vm: AreaCalcVM
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("defaultWastePercent") private var defaultWastePercent: Double = 10

    @FocusState private var focus: Field?
    @State private var showSave = false
    @State private var hasInitWaste = false
    enum Field: Hashable { case d1, d2, d3, d4, d5, price }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                shapeCard
                dimensionsCard
                openingsCard
                wasteCard
                materialCard
                if vm.isValid { resultsBlock }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Area")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if vm.isValid {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { withAnimation { vm.reset() } } label: { Text("Reset").font(.subheadline) }
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer(); Button("Done") { focus = nil }
            }
        }
        .sheet(isPresented: $showSave) {
            SaveLineItemSheet(
                calculator: .area,
                suggestedTitle: "\(vm.selected.name) — \(String(format: "%.1f", units.areaFromMetric(vm.areaMetric)))\(units.areaUnit)",
                materialName: vm.selected.name,
                materialUnit: units.unit(for: vm.selected.id),
                quantity: vm.selected.quantity(for: vm.areaMetric, units: units),
                unitPrice: Double(vm.pricePerUnit) ?? 0,
                detailJSON: detailJSON(),
                unitSystem: units
            )
        }
        .onAppear {
            if !hasInitWaste { vm.wastePercent = defaultWastePercent; hasInitWaste = true }
        }
    }

    private var shapeCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("SHAPE").font(.caption).foregroundColor(.white.opacity(0.3))
                ShapePicker(selection: $vm.shape)
            }
        }
    }

    @ViewBuilder
    private var dimensionsCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                let count = vm.shape.inputCount
                NeoField(label: "\(vm.shape.label(0)) (\(units.lengthUnit))", text: $vm.width).focused($focus, equals: .d1)
                if count >= 2 {
                    NeoField(label: "\(vm.shape.label(1)) (\(units.lengthUnit))", text: $vm.height).focused($focus, equals: .d2)
                }
                if count >= 3 {
                    NeoField(label: "\(vm.shape.label(2)) (\(units.lengthUnit))", text: $vm.dim2).focused($focus, equals: .d3)
                }
                if count >= 4 {
                    NeoField(label: "\(vm.shape.label(3)) (\(units.lengthUnit))", text: $vm.dim3).focused($focus, equals: .d4)
                }
                if count >= 5 {
                    NeoField(label: "\(vm.shape.label(4)) (\(units.lengthUnit))", text: $vm.dim4).focused($focus, equals: .d5)
                }
                NeoField(label: "Price / unit (\(currencySymbol))", text: $vm.pricePerUnit, icon: "dollarsign").focused($focus, equals: .price)
            }
        }
    }

    private var openingsCard: some View {
        GlassCard {
            OpeningsEditor(openings: $vm.openings, units: units)
        }
    }

    private var wasteCard: some View {
        GlassCard {
            WastePercentField(value: $vm.wastePercent)
        }
    }

    private var materialCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("MATERIAL").font(.caption).foregroundColor(.white.opacity(0.3))
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(MaterialPreset.all.prefix(5)) { p in
                        MatChip(name: p.name, icon: p.icon, color: p.color, selected: vm.selected.id == p.id) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { vm.selected = p }
                        }
                    }
                }
            }
        }
    }

    private var resultsBlock: some View {
        VStack(spacing: 10) {
            ResultCard(icon: "square.split.bottomrightquarter", color: .cyan,
                       title: "Net area",
                       value: "\(String(format: "%.2f", units.areaFromMetric(vm.areaMetric))) \(units.areaUnit)")
            if vm.openings.isEmpty == false {
                ResultCard(icon: "rectangle.dashed", color: .gray,
                           title: "Subtracted openings",
                           value: "\(String(format: "%.2f", units.areaFromMetric(vm.openingsAreaMetric))) \(units.areaUnit)")
            }
            ResultCard(icon: vm.selected.icon, color: vm.selected.color,
                       title: vm.selected.name,
                       value: "\(String(format: "%.1f", vm.selected.quantity(for: vm.areaMetric, units: units))) \(units.unit(for: vm.selected.id))")
            if let price = Double(vm.pricePerUnit), price > 0 {
                let cost = vm.selected.quantity(for: vm.areaMetric, units: units) * price
                ResultCard(icon: "dollarsign.circle", color: .green,
                           title: "Cost",
                           value: Currency.format(cost, code: currencyCode),
                           highlighted: true)
            }
            CTAButton(label: "Save to project", icon: "square.and.arrow.down") {
                showSave = true
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func detailJSON() -> String {
        let dict: [String: Any] = [
            "shape": vm.shape.rawValue,
            "waste": vm.wastePercent,
            "openings": vm.openings.count,
        ]
        return (try? JSONSerialization.data(withJSONObject: dict)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }
}
