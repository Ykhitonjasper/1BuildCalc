import Foundation
import SwiftData

enum MaterialCategory: String, Codable, CaseIterable, Identifiable {
    case tile, paint, primer, concrete, cement, sand, gravel
    case rebar, drywall, profile, screw, putty, tape
    case laminate, underlay, parquet, screed
    case brick, mortar, plaster, insulation, wallpaper, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tile: "Tile"
        case .paint: "Paint"
        case .primer: "Primer"
        case .concrete: "Concrete"
        case .cement: "Cement"
        case .sand: "Sand"
        case .gravel: "Gravel"
        case .rebar: "Rebar"
        case .drywall: "Drywall"
        case .profile: "Profile"
        case .screw: "Screws"
        case .putty: "Putty"
        case .tape: "Joint tape"
        case .laminate: "Laminate"
        case .underlay: "Underlay"
        case .parquet: "Parquet"
        case .screed: "Screed mix"
        case .brick: "Brick"
        case .mortar: "Mortar"
        case .plaster: "Plaster"
        case .insulation: "Insulation"
        case .wallpaper: "Wallpaper"
        case .other: "Other"
        }
    }

    var iconSF: String {
        switch self {
        case .tile: "square.grid.2x2"
        case .paint, .primer: "paintbrush"
        case .concrete, .cement: "cube.fill"
        case .sand: "circle.grid.3x3.fill"
        case .gravel: "circle.dotted"
        case .rebar: "line.diagonal"
        case .drywall: "rectangle.portrait"
        case .profile: "rectangle.stack"
        case .screw: "screwdriver"
        case .putty, .plaster: "paintpalette"
        case .tape: "ruler"
        case .laminate, .parquet: "square"
        case .underlay: "rectangle.split.3x1"
        case .screed: "square.fill"
        case .brick: "square.grid.3x3"
        case .mortar: "drop.fill"
        case .insulation: "thermometer"
        case .wallpaper: "doc.richtext"
        case .other: "cube"
        }
    }

    var defaultUnit: String {
        switch self {
        case .tile, .brick, .screw: "pcs"
        case .paint, .primer, .mortar: "L"
        case .concrete: "m³"
        case .cement, .sand, .gravel, .putty, .plaster, .screed: "kg"
        case .rebar, .profile, .tape: "m"
        case .drywall, .laminate, .parquet, .underlay, .insulation: "m²"
        case .wallpaper: "roll"
        case .other: "pcs"
        }
    }
}

@Model
final class Material {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var unit: String
    /// Consumption per m² (for area-based materials) or per m³ (for volumetric) or fixed (pcs).
    var consumption: Double
    var pricePerUnit: Double
    var hexColor: String
    var iconSF: String
    var isUserCreated: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: MaterialCategory,
        unit: String? = nil,
        consumption: Double,
        pricePerUnit: Double = 0,
        hexColor: String = "7B7B7B",
        iconSF: String? = nil,
        isUserCreated: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = category.rawValue
        self.unit = unit ?? category.defaultUnit
        self.consumption = consumption
        self.pricePerUnit = pricePerUnit
        self.hexColor = hexColor
        self.iconSF = iconSF ?? category.iconSF
        self.isUserCreated = isUserCreated
        self.createdAt = createdAt
    }

    var category: MaterialCategory {
        MaterialCategory(rawValue: categoryRaw) ?? .other
    }
}
