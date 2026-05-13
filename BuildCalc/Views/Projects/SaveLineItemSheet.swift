import SwiftUI
import SwiftData

/// Reusable sheet that lets a calculator save its result either as a brand-new
/// single-item project or into an existing project.
struct SaveLineItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @AppStorage("defaultTaxPercent") private var defaultTaxPercent: Double = 0
    @Query(sort: [SortDescriptor(\Project.updatedAt, order: .reverse)]) private var existingProjects: [Project]

    let calculator: CalculatorKind
    let suggestedTitle: String
    let materialName: String
    let materialUnit: String
    let quantity: Double
    let unitPrice: Double
    let detailJSON: String
    let unitSystem: UnitSystem

    @State private var mode: Mode = .new
    @State private var newProjectName: String = ""
    @State private var selectedProjectID: PersistentIdentifier?

    enum Mode: String, CaseIterable, Identifiable {
        case new = "New project"
        case existing = "Existing project"
        var id: String { rawValue }
    }

    var subtotal: Double { quantity * unitPrice }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBg()
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("LINE ITEM").font(.caption).foregroundColor(.white.opacity(0.4))
                                row("Title", suggestedTitle)
                                row("Material", materialName)
                                row("Quantity", String(format: "%.2f \(materialUnit)", quantity))
                                row("Unit price", Currency.format(unitPrice, code: currencyCode))
                                Divider().background(.white.opacity(0.1))
                                row("Subtotal", Currency.format(subtotal, code: currencyCode), highlight: true)
                            }
                        }

                        Picker("Destination", selection: $mode) {
                            ForEach(Mode.allCases) { m in Text(m.rawValue).tag(m) }
                        }
                        .pickerStyle(.segmented)

                        GlassCard {
                            if mode == .new {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("PROJECT NAME").font(.caption).foregroundColor(.white.opacity(0.4))
                                    TextField("New project", text: $newProjectName)
                                        .textFieldStyle(.plain)
                                        .padding(10)
                                        .background(.white.opacity(0.05))
                                        .cornerRadius(10)
                                        .foregroundColor(.white)
                                }
                            } else {
                                if existingProjects.isEmpty {
                                    Text("No saved projects yet.").foregroundColor(.white.opacity(0.5))
                                } else {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(existingProjects) { p in
                                            Button {
                                                selectedProjectID = p.persistentModelID
                                            } label: {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(p.name).font(.subheadline).foregroundColor(.white)
                                                        Text("\(p.lineItems.count) items").font(.caption).foregroundColor(.white.opacity(0.4))
                                                    }
                                                    Spacer()
                                                    if selectedProjectID == p.persistentModelID {
                                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.orange)
                                                    }
                                                }
                                                .padding(10)
                                                .background(.white.opacity(0.05))
                                                .cornerRadius(10)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        CTAButton(label: "Save", icon: "square.and.arrow.down") {
                            save()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Save line item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
            }
            .onAppear {
                if newProjectName.isEmpty { newProjectName = suggestedTitle }
                if mode == .existing, selectedProjectID == nil {
                    selectedProjectID = existingProjects.first?.persistentModelID
                }
            }
        }
    }

    private func save() {
        let project: Project
        switch mode {
        case .new:
            let name = newProjectName.trimmingCharacters(in: .whitespaces)
            let p = Project(
                name: name.isEmpty ? suggestedTitle : name,
                taxPercent: defaultTaxPercent,
                currencyCode: currencyCode,
                unitSystemRaw: unitSystem.rawValue
            )
            modelContext.insert(p)
            project = p
        case .existing:
            guard let id = selectedProjectID,
                  let p = existingProjects.first(where: { $0.persistentModelID == id }) else {
                return
            }
            project = p
            project.updatedAt = Date()
        }

        let item = LineItem(
            calculator: calculator,
            title: suggestedTitle,
            detailJSON: detailJSON,
            materialName: materialName,
            materialUnit: materialUnit,
            quantity: quantity,
            unitPrice: unitPrice,
            project: project
        )
        modelContext.insert(item)
        try? modelContext.save()
        dismiss()
    }

    private func row(_ label: String, _ value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(highlight ? .subheadline.bold().monospacedDigit() : .subheadline.monospacedDigit())
                .foregroundColor(highlight ? .green : .white)
        }
    }
}
