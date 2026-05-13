import SwiftUI

struct OpeningsEditor: View {
    @Binding var openings: [Opening]
    var units: UnitSystem
    @State private var showAdd = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("OPENINGS").font(.caption).foregroundColor(.white.opacity(0.3))
                Spacer()
                Button {
                    showAdd = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add").font(.caption.bold())
                    }
                    .foregroundColor(.orange)
                }
            }
            if openings.isEmpty {
                Text("No windows or doors").font(.caption2).foregroundColor(.white.opacity(0.3))
            } else {
                ForEach($openings) { $opening in
                    OpeningRow(opening: $opening, units: units) {
                        openings.removeAll { $0.id == opening.id }
                    }
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddOpeningSheet(units: units) { new in
                openings.append(new)
            }
            .presentationDetents([.medium])
        }
    }
}

private struct OpeningRow: View {
    @Binding var opening: Opening
    var units: UnitSystem
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: opening.kind.iconSF).foregroundColor(.cyan).frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(opening.kind.rawValue).font(.subheadline).foregroundColor(.white)
                Text("\(formatDim(opening.width)) × \(formatDim(opening.height)) \(units.lengthUnit) × \(opening.count)")
                    .font(.caption2).foregroundColor(.white.opacity(0.5))
            }
            Spacer()
            Text(String(format: "%.2f \(units.areaUnit)", units.areaFromMetric(opening.area)))
                .font(.caption.monospacedDigit())
                .foregroundColor(.orange)
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash").foregroundColor(.red.opacity(0.8))
            }
        }
        .padding(10)
        .background(.white.opacity(0.04))
        .cornerRadius(10)
    }

    private func formatDim(_ metric: Double) -> String {
        let v = units.fromMetric(metric)
        return String(format: "%.2f", v)
    }
}

private struct AddOpeningSheet: View {
    var units: UnitSystem
    var onAdd: (Opening) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var kind: Opening.Kind = .window
    @State private var width: String = ""
    @State private var height: String = ""
    @State private var count: Int = 1

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBg()
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard {
                            VStack(spacing: 12) {
                                Picker("Kind", selection: $kind) {
                                    ForEach(Opening.Kind.allCases) { k in
                                        Text(k.rawValue).tag(k)
                                    }
                                }
                                .pickerStyle(.segmented)
                                HStack(spacing: 10) {
                                    NeoField(label: "Width (\(units.lengthUnit))", text: $width)
                                    NeoField(label: "Height (\(units.lengthUnit))", text: $height)
                                }
                                Stepper("Count: \(count)", value: $count, in: 1...20)
                                    .foregroundColor(.white)
                            }
                        }
                        CTAButton(label: "Add opening", icon: "checkmark.circle.fill") {
                            let w = units.toMetric(Double(width) ?? 0)
                            let h = units.toMetric(Double(height) ?? 0)
                            guard w > 0, h > 0 else { return }
                            onAdd(Opening(kind: kind, width: w, height: h, count: count))
                            dismiss()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("New opening")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                let d = kind.defaultSize
                width = String(format: "%.2f", units.fromMetric(d.width))
                height = String(format: "%.2f", units.fromMetric(d.height))
            }
            .onChange(of: kind) { _, k in
                let d = k.defaultSize
                width = String(format: "%.2f", units.fromMetric(d.width))
                height = String(format: "%.2f", units.fromMetric(d.height))
            }
        }
    }
}
