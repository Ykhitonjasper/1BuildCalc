import SwiftUI
import PDFKit

struct EstimateExportView: View {
    let project: Project
    @Environment(\.dismiss) private var dismiss
    @State private var pdfData: Data?
    @State private var format: Format = .pdf

    enum Format: String, CaseIterable, Identifiable {
        case pdf = "PDF"
        case csv = "CSV"
        case text = "Text"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBg()
                VStack(spacing: 12) {
                    Picker("Format", selection: $format) {
                        ForEach(Format.allCases) { f in Text(f.rawValue).tag(f) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)

                    Group {
                        switch format {
                        case .pdf:
                            if let data = pdfData {
                                PDFKitView(data: data)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                            } else {
                                ProgressView().tint(.white)
                            }
                        case .csv:
                            ScrollView {
                                Text(EstimateExporter.renderCSV(project: project))
                                    .font(.caption.monospaced())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                            }
                            .background(.white.opacity(0.04))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        case .text:
                            ScrollView {
                                Text(EstimateExporter.renderText(project: project))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                            }
                            .background(.white.opacity(0.04))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }
                    }

                    shareButton
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
                .padding(.top, 12)
            }
            .navigationTitle("Export estimate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } }
            }
            .task { generatePDF() }
        }
    }

    private var fileBase: String {
        let safe = project.name.replacingOccurrences(of: "/", with: "-").trimmingCharacters(in: .whitespaces)
        return safe.isEmpty ? "estimate" : safe
    }

    @ViewBuilder
    private var shareButton: some View {
        switch format {
        case .pdf:
            if let data = pdfData {
                ShareLink(item: EstimateExporter.writeTempFile(name: "\(fileBase).pdf", data: data)) {
                    label("Share PDF")
                }
            }
        case .csv:
            let url = EstimateExporter.writeTempFile(name: "\(fileBase).csv", string: EstimateExporter.renderCSV(project: project))
            ShareLink(item: url) { label("Share CSV") }
        case .text:
            ShareLink(item: EstimateExporter.renderText(project: project)) {
                label("Share text")
            }
        }
    }

    private func label(_ text: String) -> some View {
        HStack {
            Image(systemName: "square.and.arrow.up")
            Text(text)
        }
        .font(.subheadline.bold())
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(LinearGradient(colors: [.orange, Color(hex: "FF6B35")], startPoint: .leading, endPoint: .trailing))
        .cornerRadius(14)
    }

    @MainActor
    private func generatePDF() {
        pdfData = EstimateExporter.renderPDF(project: project)
    }
}

private struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.backgroundColor = .black
        v.document = PDFDocument(data: data)
        return v
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(data: data)
    }
}
