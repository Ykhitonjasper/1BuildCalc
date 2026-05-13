import Foundation
import SwiftData

enum CalculatorKind: String, Codable, CaseIterable, Identifiable {
    case area, volume, wallpaper
    case concrete, tile, paint, drywall, laminate, screed, brick, plaster

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .area: "Area"
        case .volume: "Volume"
        case .wallpaper: "Wallpaper"
        case .concrete: "Concrete"
        case .tile: "Tile"
        case .paint: "Paint"
        case .drywall: "Drywall"
        case .laminate: "Laminate"
        case .screed: "Screed"
        case .brick: "Brick"
        case .plaster: "Plaster"
        }
    }

    var iconSF: String {
        switch self {
        case .area: "square.split.bottomrightquarter"
        case .volume: "cube.fill"
        case .wallpaper: "doc.richtext"
        case .concrete: "cube.transparent"
        case .tile: "square.grid.2x2"
        case .paint: "paintbrush.fill"
        case .drywall: "rectangle.portrait"
        case .laminate: "square.stack"
        case .screed: "square.fill"
        case .brick: "square.grid.3x3"
        case .plaster: "paintpalette.fill"
        }
    }
}

@Model
final class LineItem {
    @Attribute(.unique) var id: UUID
    var calculatorTypeRaw: String
    var title: String
    var detailJSON: String
    var materialName: String
    var materialUnit: String
    var quantity: Double
    var unitPrice: Double
    var subtotal: Double
    var createdAt: Date
    var project: Project?

    init(
        id: UUID = UUID(),
        calculator: CalculatorKind,
        title: String,
        detailJSON: String = "{}",
        materialName: String,
        materialUnit: String,
        quantity: Double,
        unitPrice: Double,
        subtotal: Double? = nil,
        createdAt: Date = Date(),
        project: Project? = nil
    ) {
        self.id = id
        self.calculatorTypeRaw = calculator.rawValue
        self.title = title
        self.detailJSON = detailJSON
        self.materialName = materialName
        self.materialUnit = materialUnit
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.subtotal = subtotal ?? (quantity * unitPrice)
        self.createdAt = createdAt
        self.project = project
    }

    var calculator: CalculatorKind {
        CalculatorKind(rawValue: calculatorTypeRaw) ?? .area
    }
}
