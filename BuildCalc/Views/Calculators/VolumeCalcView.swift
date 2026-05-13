import SwiftUI
import SwiftData

struct VolumeCalcView: View {
    @EnvironmentObject var vm: VolumeCalcVM
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("defaultWastePercent") private var defaultWastePercent: Double = 10

    @FocusState private var focus: Field?
    @State private var showSave = false
    @State private var hasInitWaste = false
    enum Field { case l, w, d, p }

    var units: UnitSystem { useImperial ? .imperial : .metric }
    private var currencySymbol: String { Currency.from(code: currencyCode).symbol }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 12) {
                        NeoField(label: "Length (\(units.lengthUnit))", text: $vm.length).focused($focus, equals: .l)
                        HStack(spacing: 10) {
                            NeoField(label: "Width (\(units.lengthUnit))", text: $vm.width).focused($focus, equals: .w)
                            Text("×").foregroundColor(.white.opacity(0.3)).font(.title2.bold())
                            NeoField(label: "Depth (\(units.lengthUnit))", text: $vm.depth).focused($focus, equals: .d)
                        }
                        NeoField(label: "Price / unit (\(currencySymbol))", text: $vm.pricePerUnit, icon: "dollarsign").focused($focus, equals: .p)
                    }
                }
                GlassCard { WastePercentField(value: $vm.wastePercent) }
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("MATERIAL").font(.caption).foregroundColor(.white.opacity(0.3))
                        HStack(spacing: 8) {
                            ForEach([MaterialPreset.all[5], MaterialPreset.all[0], MaterialPreset.all[3]], id: \.id) { p in
                                MatChip(name: p.name, icon: p.icon, color: p.color, selected: vm.selected.id == p.id) {
                                    withAnimation { vm.selected = p }
                                }
                            }
                        }
                    }
                }
                if vm.isValid {
                    let qty = vm.selected.quantity(for: vm.volumeMetric, units: units)
                    let price = Double(vm.pricePerUnit) ?? 0
                    VStack(spacing: 10) {
                        ResultCard(icon: "cube.fill", color: .cyan, title: "Volume",
                                   value: "\(String(format: "%.3f", units.volumeFromMetric(vm.volumeMetric))) \(units.volumeUnit)")
                        ResultCard(icon: vm.selected.icon, color: vm.selected.color,
                                   title: vm.selected.name,
                                   value: "\(String(format: "%.1f", qty)) \(units.unit(for: vm.selected.id))")
                        if price > 0 {
                            ResultCard(icon: "dollarsign.circle", color: .green, title: "Cost",
                                       value: Currency.format(qty * price, code: currencyCode), highlighted: true)
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
        .navigationTitle("Volume")
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
            let qty = vm.selected.quantity(for: vm.volumeMetric, units: units)
            let price = Double(vm.pricePerUnit) ?? 0
            SaveLineItemSheet(
                calculator: .volume,
                suggestedTitle: "Volume — \(String(format: "%.2f", units.volumeFromMetric(vm.volumeMetric)))\(units.volumeUnit)",
                materialName: vm.selected.name,
                materialUnit: units.unit(for: vm.selected.id),
                quantity: qty,
                unitPrice: price,
                detailJSON: "{}",
                unitSystem: units
            )
        }
        .onAppear { if !hasInitWaste { vm.wastePercent = defaultWastePercent; hasInitWaste = true } }
    }
}
