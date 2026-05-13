import Foundation

/// Default materials inserted into the SwiftData catalog on first launch.
/// All consumptions are "per m²" (or per m³ where noted in comments). Prices are sane USD defaults
/// that the user is expected to override in the catalog.
struct MaterialSeed {
    let name: String
    let category: MaterialCategory
    let unit: String?
    let consumption: Double
    let price: Double
    let hexColor: String

    func makeMaterial() -> Material {
        Material(
            name: name,
            category: category,
            unit: unit,
            consumption: consumption,
            pricePerUnit: price,
            hexColor: hexColor,
            isUserCreated: false
        )
    }

    // MARK: - Defaults

    static let defaults: [MaterialSeed] = [
        // --- Tiles & adhesives ---
        .init(name: "Ceramic tile 300×300", category: .tile, unit: "pcs", consumption: 11.11, price: 1.50, hexColor: "00B4D8"),
        .init(name: "Ceramic tile 600×600", category: .tile, unit: "pcs", consumption: 2.78, price: 4.50, hexColor: "0096C7"),
        .init(name: "Porcelain tile 600×1200", category: .tile, unit: "pcs", consumption: 1.39, price: 12.0, hexColor: "0077B6"),
        .init(name: "Tile adhesive", category: .other, unit: "kg", consumption: 4.5, price: 0.80, hexColor: "8D99AE"),
        .init(name: "Grout 2 mm", category: .other, unit: "kg", consumption: 0.30, price: 4.0, hexColor: "BDB2FF"),

        // --- Paint & primer ---
        .init(name: "Wall paint matte", category: .paint, unit: "L", consumption: 0.14, price: 12.0, hexColor: "7B2FBE"),
        .init(name: "Wall paint silk", category: .paint, unit: "L", consumption: 0.13, price: 18.0, hexColor: "9D4EDD"),
        .init(name: "Ceiling paint", category: .paint, unit: "L", consumption: 0.15, price: 10.0, hexColor: "E0AAFF"),
        .init(name: "Primer deep penetrating", category: .primer, unit: "L", consumption: 0.15, price: 6.0, hexColor: "C77DFF"),

        // --- Concrete & components ---
        .init(name: "Concrete M200", category: .concrete, unit: "m³", consumption: 1.0, price: 120.0, hexColor: "6B7280"),
        .init(name: "Concrete M250", category: .concrete, unit: "m³", consumption: 1.0, price: 135.0, hexColor: "6B7280"),
        .init(name: "Concrete M300", category: .concrete, unit: "m³", consumption: 1.0, price: 150.0, hexColor: "6B7280"),
        .init(name: "Portland cement", category: .cement, unit: "kg", consumption: 320.0, price: 0.20, hexColor: "ADB5BD"),
        .init(name: "Sand", category: .sand, unit: "kg", consumption: 600.0, price: 0.05, hexColor: "F4A261"),
        .init(name: "Gravel 5-20 mm", category: .gravel, unit: "kg", consumption: 1100.0, price: 0.06, hexColor: "A0A0A0"),

        // --- Rebar (consumption stored per m of rebar — quantity comes from calc) ---
        .init(name: "Rebar Ø8 mm", category: .rebar, unit: "m", consumption: 0.395, price: 0.45, hexColor: "FF6B35"),
        .init(name: "Rebar Ø10 mm", category: .rebar, unit: "m", consumption: 0.617, price: 0.60, hexColor: "FF6B35"),
        .init(name: "Rebar Ø12 mm", category: .rebar, unit: "m", consumption: 0.888, price: 0.85, hexColor: "FF6B35"),
        .init(name: "Rebar Ø14 mm", category: .rebar, unit: "m", consumption: 1.21,  price: 1.15, hexColor: "FF6B35"),
        .init(name: "Rebar Ø16 mm", category: .rebar, unit: "m", consumption: 1.58,  price: 1.55, hexColor: "FF6B35"),

        // --- Drywall ---
        .init(name: "Drywall sheet 12.5 mm", category: .drywall, unit: "m²", consumption: 1.05, price: 4.0, hexColor: "F8F9FA"),
        .init(name: "Profile UD 27", category: .profile, unit: "m", consumption: 0.6, price: 1.20, hexColor: "ADB5BD"),
        .init(name: "Profile CD 60", category: .profile, unit: "m", consumption: 2.0, price: 1.50, hexColor: "868E96"),
        .init(name: "Drywall screws 25 mm", category: .screw, unit: "pcs", consumption: 25, price: 0.02, hexColor: "495057"),
        .init(name: "Joint tape", category: .tape, unit: "m", consumption: 1.5, price: 0.10, hexColor: "DEE2E6"),
        .init(name: "Joint putty", category: .putty, unit: "kg", consumption: 1.2, price: 1.20, hexColor: "E9ECEF"),

        // --- Flooring ---
        .init(name: "Laminate 32 class", category: .laminate, unit: "m²", consumption: 1.07, price: 18.0, hexColor: "C9A96E"),
        .init(name: "Laminate 33 class", category: .laminate, unit: "m²", consumption: 1.07, price: 26.0, hexColor: "B58863"),
        .init(name: "Underlay 3 mm", category: .underlay, unit: "m²", consumption: 1.05, price: 1.50, hexColor: "FFD6A5"),

        // --- Screed ---
        .init(name: "Cement-sand screed mix", category: .screed, unit: "kg", consumption: 18.0, price: 0.15, hexColor: "ADB5BD"),
        .init(name: "Self-leveling compound", category: .screed, unit: "kg", consumption: 1.6, price: 0.50, hexColor: "DEE2E6"),

        // --- Brick & mortar ---
        .init(name: "Single brick 250×120×65", category: .brick, unit: "pcs", consumption: 51, price: 0.45, hexColor: "B85C38"),
        .init(name: "One-and-a-half brick 250×120×88", category: .brick, unit: "pcs", consumption: 39, price: 0.55, hexColor: "A04E2F"),
        .init(name: "Masonry mortar", category: .mortar, unit: "L", consumption: 75.0, price: 0.20, hexColor: "ADB5BD"),

        // --- Plaster ---
        .init(name: "Gypsum plaster", category: .plaster, unit: "kg", consumption: 8.5, price: 0.45, hexColor: "F1FAEE"),
        .init(name: "Cement plaster", category: .plaster, unit: "kg", consumption: 16.0, price: 0.25, hexColor: "ADB5BD"),

        // --- Wallpaper ---
        .init(name: "Wallpaper roll 10×1.06 m", category: .wallpaper, unit: "roll", consumption: 1.0, price: 25.0, hexColor: "FF6B35"),
    ]
}
