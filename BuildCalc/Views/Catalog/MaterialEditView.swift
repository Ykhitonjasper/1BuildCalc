import SwiftUI
import SwiftData

struct MaterialEditView: View {
    @Bindable var material: Material
    let isNew: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currencyCode") private var currencyCode: String = "USD"

    @State private var consumptionText: String = ""
    @State private var priceText: String = ""

    var body: some View {
        ZStack {
            GlassBg()
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard {
                        VStack(spacing: 12) {
                            LabeledField(label: "NAME", text: $material.name)
                            HStack(spacing: 10) {
                                pickerCard(title: "CATEGORY") {
                                    Picker("Category", selection: Binding(
                                        get: { material.category },
                                        set: { material.categoryRaw = $0.rawValue }
                                    )) {
                                        ForEach(MaterialCategory.allCases) { c in
                                            Text(c.displayName).tag(c)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.orange)
                                }
                                LabeledField(label: "UNIT", text: $material.unit)
                            }
                        }
                    }
                    GlassCard {
                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                NumericLabeledField(label: "CONSUMPTION / m²", text: $consumptionText) { val in
                                    material.consumption = val
                                }
                                NumericLabeledField(label: "PRICE / \(material.unit) (\(Currency.from(code: currencyCode).symbol))", text: $priceText) { val in
                                    material.pricePerUnit = val
                                }
                            }
                            Text("Consumption is how much of this material is needed for one square metre of finished work (or one cubic metre for volumetric materials).")
                                .font(.caption2).foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(isNew ? "New material" : "Edit material")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    try? modelContext.save()
                    dismiss()
                }.bold()
            }
        }
        .onAppear {
            consumptionText = String(format: "%g", material.consumption)
            priceText = String(format: "%g", material.pricePerUnit)
        }
    }

    private func pickerCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.caption).foregroundColor(.white.opacity(0.5))
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.06), lineWidth: 0.5))
    }
}

private struct LabeledField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            TextField("", text: $text)
                .padding(.vertical, 8)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.06), lineWidth: 0.5))
    }
}

private struct NumericLabeledField: View {
    let label: String
    @Binding var text: String
    let onChange: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5)).lineLimit(1).minimumScaleFactor(0.7)
            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .font(.title3.monospacedDigit())
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .onChange(of: text) { _, new in
                    if let v = Double(new.replacingOccurrences(of: ",", with: ".")) {
                        onChange(v)
                    }
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.06), lineWidth: 0.5))
    }
}
