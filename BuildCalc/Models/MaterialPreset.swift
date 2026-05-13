import SwiftUI

/// Built-in starter presets shown directly in calculators. The SwiftData material
/// catalog (Phase 3) extends this with user materials; until then, calculators
/// reference these presets directly.
struct MaterialPreset: Identifiable {
    let id: String
    let name: String
    let unit: String
    /// Quantity per m² of computed area (or m³ for volumetric materials marked id="concrete").
    let perSquareMeter: Double
    let icon: String
    let color: Color

    static let all: [MaterialPreset] = [
        MaterialPreset(id: "brick",    name: "Brick",    unit: "pcs", perSquareMeter: 60,   icon: "square.grid.3x3",  color: Color(hex: "FF6B35")),
        MaterialPreset(id: "tile",     name: "Tile",     unit: "pcs", perSquareMeter: 25,   icon: "square.grid.2x2",  color: Color(hex: "00B4D8")),
        MaterialPreset(id: "paint",    name: "Paint",    unit: "L",   perSquareMeter: 0.15, icon: "paintbrush",       color: Color(hex: "7B2FBE")),
        MaterialPreset(id: "plaster",  name: "Plaster",  unit: "kg",  perSquareMeter: 8.5,  icon: "rectangle.fill",   color: Color(hex: "A0A0A0")),
        MaterialPreset(id: "laminate", name: "Laminate", unit: "m²",  perSquareMeter: 1.08, icon: "square",           color: Color(hex: "C9A96E")),
        MaterialPreset(id: "concrete", name: "Concrete", unit: "m³",  perSquareMeter: 1.0,  icon: "cube.fill",        color: Color(hex: "6B7280")),
    ]

    func quantity(for areaMetric: Double, units: UnitSystem) -> Double {
        let qty = areaMetric * perSquareMeter
        guard units != .metric else { return qty }
        switch id {
        case "paint":    return qty * 0.264   // L → gal
        case "plaster":  return qty * 2.205   // kg → lb
        case "laminate": return qty * 10.764  // m² → ft²
        case "concrete": return qty * 35.315  // m³ → ft³
        default:         return qty           // pcs stay pcs
        }
    }
}
