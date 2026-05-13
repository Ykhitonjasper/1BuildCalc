import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Bindable var project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var showEdit = false
    @State private var showExport = false

    var body: some View {
        ZStack {
            GlassBg()
            ScrollView {
                VStack(spacing: 18) {
                    GlassCard {
                        VStack(spacing: 6) {
                            Text(project.name).font(.title2.bold()).foregroundColor(.white).multilineTextAlignment(.center)
                            if !project.clientName.isEmpty {
                                Text(project.clientName).font(.subheadline).foregroundColor(.orange)
                            }
                            Text(project.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2).foregroundColor(.white.opacity(0.3))
                        }.frame(maxWidth: .infinity)
                    }

                    if !project.clientName.isEmpty || !project.clientAddress.isEmpty || !project.clientPhone.isEmpty {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CLIENT").font(.caption).foregroundColor(.white.opacity(0.4))
                                if !project.clientName.isEmpty { row("Name", project.clientName) }
                                if !project.clientAddress.isEmpty { row("Address", project.clientAddress) }
                                if !project.clientPhone.isEmpty { row("Phone", project.clientPhone) }
                            }
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LINE ITEMS").font(.caption).foregroundColor(.white.opacity(0.4))
                            if project.lineItems.isEmpty {
                                Text("No items yet.").font(.subheadline).foregroundColor(.white.opacity(0.4))
                            } else {
                                ForEach(project.lineItems.sorted(by: { $0.createdAt < $1.createdAt })) { item in
                                    LineItemRow(item: item, currencyCode: project.currencyCode)
                                }
                            }
                        }
                    }

                    if !project.notes.isEmpty {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("NOTES").font(.caption).foregroundColor(.white.opacity(0.4))
                                Text(project.notes).font(.subheadline).foregroundColor(.white)
                            }
                        }
                    }

                    GlassCard {
                        VStack(spacing: 8) {
                            row("Subtotal", Currency.format(project.subtotal, code: project.currencyCode))
                            if project.taxPercent > 0 {
                                row(String(format: "VAT %.0f%%", project.taxPercent),
                                    Currency.format(project.taxAmount, code: project.currencyCode))
                            }
                            Divider().background(.white.opacity(0.1))
                            row("Total", Currency.format(project.total, code: project.currencyCode), highlight: true)
                        }
                    }

                    HStack(spacing: 10) {
                        Button {
                            showExport = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.green.opacity(0.7))
                            .cornerRadius(12)
                        }
                        Button {
                            showEdit = true
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.orange.opacity(0.7))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEdit) {
            ProjectEditView(project: project)
        }
        .sheet(isPresented: $showExport) {
            EstimateExportView(project: project)
        }
    }

    private func row(_ label: String, _ value: String, highlight: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(label).font(.subheadline).foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(highlight ? .title3.bold().monospacedDigit() : .subheadline.monospacedDigit())
                .foregroundColor(highlight ? .green : .white)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct LineItemRow: View {
    let item: LineItem
    let currencyCode: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.calculator.iconSF)
                .font(.subheadline).foregroundColor(.orange)
                .frame(width: 32, height: 32)
                .background(.orange.opacity(0.12))
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title).font(.subheadline.bold()).foregroundColor(.white).lineLimit(1)
                Text("\(item.materialName) • \(String(format: "%.2f", item.quantity)) \(item.materialUnit)")
                    .font(.caption).foregroundColor(.white.opacity(0.4)).lineLimit(1)
            }
            Spacer()
            if item.subtotal > 0 {
                Text(Currency.format(item.subtotal, code: currencyCode))
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}
