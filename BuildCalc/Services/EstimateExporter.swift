import SwiftUI
import UIKit
import PDFKit

enum EstimateExporter {

    // MARK: - PDF

    /// Renders an `EstimateDocumentView` into PDF data via `UIGraphicsPDFRenderer`.
    @MainActor
    static func renderPDF(project: Project) -> Data {
        let pageSize = CGSize(width: 595, height: 842) // A4 @ 72dpi

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        let data = renderer.pdfData { ctx in
            let chunks = chunkLineItems(project.lineItems.sorted(by: { $0.createdAt < $1.createdAt }),
                                        perPage: 24)
            let pageCount = max(1, chunks.count)
            for (idx, chunk) in chunks.enumerated() {
                ctx.beginPage()
                drawPage(
                    project: project,
                    items: chunk,
                    pageIndex: idx,
                    pageCount: pageCount,
                    in: ctx.cgContext,
                    size: pageSize
                )
            }
            if chunks.isEmpty {
                ctx.beginPage()
                drawPage(project: project, items: [], pageIndex: 0, pageCount: 1, in: ctx.cgContext, size: pageSize)
            }
        }
        return data
    }

    private static func chunkLineItems(_ items: [LineItem], perPage: Int) -> [[LineItem]] {
        guard !items.isEmpty else { return [] }
        var result: [[LineItem]] = []
        var current: [LineItem] = []
        for item in items {
            current.append(item)
            if current.count == perPage {
                result.append(current); current = []
            }
        }
        if !current.isEmpty { result.append(current) }
        return result
    }

    private static func drawPage(
        project: Project,
        items: [LineItem],
        pageIndex: Int,
        pageCount: Int,
        in cg: CGContext,
        size: CGSize
    ) {
        let leftMargin: CGFloat = 36
        let rightMargin: CGFloat = 36
        let topMargin: CGFloat = 36
        let bottomMargin: CGFloat = 60
        let contentWidth = size.width - leftMargin - rightMargin
        var y: CGFloat = topMargin

        let titleAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black,
        ]
        let labelAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray,
        ]
        let bodyAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.black,
        ]
        let headerAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray,
        ]
        let totalAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 13),
            .foregroundColor: UIColor.black,
        ]

        // Header (page 1 only)
        if pageIndex == 0 {
            ("ESTIMATE" as NSString).draw(at: CGPoint(x: leftMargin, y: y), withAttributes: titleAttr)
            let dateStr = project.createdAt.formatted(date: .long, time: .omitted)
            let dateSize = (dateStr as NSString).size(withAttributes: labelAttr)
            (dateStr as NSString).draw(at: CGPoint(x: size.width - rightMargin - dateSize.width, y: y + 6),
                                       withAttributes: labelAttr)
            y += 36

            // Project info
            (project.name as NSString).draw(at: CGPoint(x: leftMargin, y: y),
                                            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14),
                                                             .foregroundColor: UIColor.black])
            y += 20

            // Client block
            if !project.clientName.isEmpty || !project.clientAddress.isEmpty || !project.clientPhone.isEmpty {
                ("CLIENT" as NSString).draw(at: CGPoint(x: leftMargin, y: y), withAttributes: headerAttr)
                y += 14
                if !project.clientName.isEmpty {
                    (project.clientName as NSString).draw(at: CGPoint(x: leftMargin, y: y), withAttributes: bodyAttr)
                    y += 14
                }
                if !project.clientAddress.isEmpty {
                    (project.clientAddress as NSString).draw(at: CGPoint(x: leftMargin, y: y), withAttributes: bodyAttr)
                    y += 14
                }
                if !project.clientPhone.isEmpty {
                    (project.clientPhone as NSString).draw(at: CGPoint(x: leftMargin, y: y), withAttributes: bodyAttr)
                    y += 14
                }
                y += 8
            }
        }

        // Table header
        let col1 = leftMargin                       // Item
        let col2 = leftMargin + contentWidth * 0.46 // Material
        let col3 = leftMargin + contentWidth * 0.70 // Qty
        let col4 = leftMargin + contentWidth * 0.84 // Unit price
        let rightEdge = size.width - rightMargin    // Subtotal (right aligned)

        cg.setStrokeColor(UIColor.lightGray.cgColor)
        cg.setLineWidth(0.5)
        cg.move(to: CGPoint(x: leftMargin, y: y))
        cg.addLine(to: CGPoint(x: size.width - rightMargin, y: y))
        cg.strokePath()
        y += 6

        ("ITEM"     as NSString).draw(at: CGPoint(x: col1, y: y), withAttributes: headerAttr)
        ("MATERIAL" as NSString).draw(at: CGPoint(x: col2, y: y), withAttributes: headerAttr)
        ("QTY"      as NSString).draw(at: CGPoint(x: col3, y: y), withAttributes: headerAttr)
        ("PRICE"    as NSString).draw(at: CGPoint(x: col4, y: y), withAttributes: headerAttr)
        let subtotalLabel = "SUBTOTAL"
        let stWidth = (subtotalLabel as NSString).size(withAttributes: headerAttr).width
        (subtotalLabel as NSString).draw(at: CGPoint(x: rightEdge - stWidth, y: y), withAttributes: headerAttr)
        y += 14

        cg.move(to: CGPoint(x: leftMargin, y: y))
        cg.addLine(to: CGPoint(x: size.width - rightMargin, y: y))
        cg.strokePath()
        y += 4

        // Rows
        for item in items {
            let title = item.title
            let mat = item.materialName
            let qty = String(format: "%.2f %@", item.quantity, item.materialUnit)
            let price = Currency.format(item.unitPrice, code: project.currencyCode)
            let sub = Currency.format(item.subtotal, code: project.currencyCode)

            (title as NSString).draw(in: CGRect(x: col1, y: y + 4, width: col2 - col1 - 6, height: 14), withAttributes: bodyAttr)
            (mat   as NSString).draw(in: CGRect(x: col2, y: y + 4, width: col3 - col2 - 6, height: 14), withAttributes: bodyAttr)
            (qty   as NSString).draw(at: CGPoint(x: col3, y: y + 4), withAttributes: bodyAttr)
            (price as NSString).draw(at: CGPoint(x: col4, y: y + 4), withAttributes: bodyAttr)
            let subW = (sub as NSString).size(withAttributes: bodyAttr).width
            (sub as NSString).draw(at: CGPoint(x: rightEdge - subW, y: y + 4), withAttributes: bodyAttr)
            y += 20

            if y > size.height - bottomMargin - 60 { break }
        }

        // Totals (last page only)
        if pageIndex == pageCount - 1 {
            y = size.height - bottomMargin - 64
            cg.move(to: CGPoint(x: leftMargin + contentWidth * 0.55, y: y))
            cg.addLine(to: CGPoint(x: size.width - rightMargin, y: y))
            cg.strokePath()
            y += 8

            drawTotalRow("Subtotal", Currency.format(project.subtotal, code: project.currencyCode), y: &y, leftX: leftMargin + contentWidth * 0.55, rightX: rightEdge, attr: bodyAttr)
            if project.taxPercent > 0 {
                drawTotalRow(String(format: "VAT %.0f%%", project.taxPercent),
                             Currency.format(project.taxAmount, code: project.currencyCode),
                             y: &y, leftX: leftMargin + contentWidth * 0.55, rightX: rightEdge, attr: bodyAttr)
            }
            drawTotalRow("TOTAL", Currency.format(project.total, code: project.currencyCode),
                         y: &y, leftX: leftMargin + contentWidth * 0.55, rightX: rightEdge, attr: totalAttr)
        }

        // Footer
        let pageStr = "Page \(pageIndex + 1) of \(pageCount)"
        let pageSize = (pageStr as NSString).size(withAttributes: labelAttr)
        (pageStr as NSString).draw(at: CGPoint(x: size.width - rightMargin - pageSize.width, y: size.height - bottomMargin + 20),
                                   withAttributes: labelAttr)
        ("Generated by BuildCalc" as NSString).draw(at: CGPoint(x: leftMargin, y: size.height - bottomMargin + 20),
                                                    withAttributes: labelAttr)
    }

    private static func drawTotalRow(_ label: String, _ value: String, y: inout CGFloat, leftX: CGFloat, rightX: CGFloat, attr: [NSAttributedString.Key: Any]) {
        (label as NSString).draw(at: CGPoint(x: leftX, y: y), withAttributes: attr)
        let vSize = (value as NSString).size(withAttributes: attr)
        (value as NSString).draw(at: CGPoint(x: rightX - vSize.width, y: y), withAttributes: attr)
        y += 18
    }

    // MARK: - CSV / text

    static func renderCSV(project: Project) -> String {
        var rows: [String] = []
        rows.append("title,material,quantity,unit,unit_price,subtotal,currency")
        for item in project.lineItems.sorted(by: { $0.createdAt < $1.createdAt }) {
            rows.append([
                csvEscape(item.title),
                csvEscape(item.materialName),
                String(format: "%.4f", item.quantity),
                csvEscape(item.materialUnit),
                String(format: "%.2f", item.unitPrice),
                String(format: "%.2f", item.subtotal),
                project.currencyCode,
            ].joined(separator: ","))
        }
        rows.append("")
        rows.append("Subtotal,,,,,\(String(format: "%.2f", project.subtotal)),\(project.currencyCode)")
        if project.taxPercent > 0 {
            rows.append("VAT \(String(format: "%.0f", project.taxPercent))%,,,,,\(String(format: "%.2f", project.taxAmount)),\(project.currencyCode)")
        }
        rows.append("Total,,,,,\(String(format: "%.2f", project.total)),\(project.currencyCode)")
        return rows.joined(separator: "\n")
    }

    static func renderText(project: Project) -> String {
        var lines: [String] = []
        lines.append("ESTIMATE — \(project.name)")
        if !project.clientName.isEmpty { lines.append("Client: \(project.clientName)") }
        if !project.clientAddress.isEmpty { lines.append("Address: \(project.clientAddress)") }
        if !project.clientPhone.isEmpty { lines.append("Phone: \(project.clientPhone)") }
        lines.append("Date: \(project.createdAt.formatted(date: .long, time: .omitted))")
        lines.append("")
        for (i, item) in project.lineItems.sorted(by: { $0.createdAt < $1.createdAt }).enumerated() {
            lines.append("\(i+1). \(item.title)")
            lines.append("   \(item.materialName) — \(String(format: "%.2f", item.quantity)) \(item.materialUnit) × \(Currency.format(item.unitPrice, code: project.currencyCode)) = \(Currency.format(item.subtotal, code: project.currencyCode))")
        }
        lines.append("")
        lines.append("Subtotal: \(Currency.format(project.subtotal, code: project.currencyCode))")
        if project.taxPercent > 0 {
            lines.append(String(format: "VAT %.0f%%: \(Currency.format(project.taxAmount, code: project.currencyCode))", project.taxPercent))
        }
        lines.append("Total: \(Currency.format(project.total, code: project.currencyCode))")
        return lines.joined(separator: "\n")
    }

    private static func csvEscape(_ s: String) -> String {
        if s.contains(",") || s.contains("\"") || s.contains("\n") {
            return "\"\(s.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return s
    }

    // MARK: - File staging

    static func writeTempFile(name: String, data: Data) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? data.write(to: url)
        return url
    }

    static func writeTempFile(name: String, string: String) -> URL {
        writeTempFile(name: name, data: Data(string.utf8))
    }
}
