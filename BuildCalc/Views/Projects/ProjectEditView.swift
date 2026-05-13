import SwiftUI
import SwiftData

struct ProjectEditView: View {
    @Bindable var project: Project
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBg()
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard {
                            VStack(spacing: 12) {
                                LabeledField(label: "PROJECT NAME", text: $project.name)
                            }
                        }
                        GlassCard {
                            VStack(spacing: 12) {
                                Text("CLIENT").font(.caption).foregroundColor(.white.opacity(0.4)).frame(maxWidth: .infinity, alignment: .leading)
                                LabeledField(label: "Name", text: $project.clientName)
                                LabeledField(label: "Address", text: $project.clientAddress)
                                LabeledField(label: "Phone", text: $project.clientPhone, keyboard: .phonePad)
                            }
                        }
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("NOTES").font(.caption).foregroundColor(.white.opacity(0.4))
                                TextEditor(text: $project.notes)
                                    .scrollContentBackground(.hidden)
                                    .background(.white.opacity(0.05))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .frame(minHeight: 80)
                            }
                        }
                        GlassCard {
                            VStack(spacing: 10) {
                                HStack {
                                    Image(systemName: "percent").foregroundColor(.blue).frame(width: 24)
                                    Text("VAT / Tax").foregroundColor(.white)
                                    Spacer()
                                    Text(String(format: "%.0f%%", project.taxPercent))
                                        .font(.subheadline.bold().monospacedDigit()).foregroundColor(.blue)
                                }
                                Slider(value: $project.taxPercent, in: 0...40, step: 1).tint(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        project.updatedAt = Date()
                        try? modelContext.save()
                        dismiss()
                    }.bold()
                }
            }
        }
    }
}

private struct LabeledField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            TextField("", text: $text)
                .keyboardType(keyboard)
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
