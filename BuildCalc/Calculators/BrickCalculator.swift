import Foundation

enum BrickKind: String, CaseIterable, Identifiable {
    case single = "Single (65 mm)"
    case oneAndHalf = "1.5 thick (88 mm)"
    case double = "Double (138 mm)"

    var id: String { rawValue }

    /// Bricks per m² of wall for the listed wall thickness, assuming 10 mm mortar joints.
    func perSquareMeter(thickness: WallThickness) -> Int {
        switch (self, thickness) {
        case (.single, .half): 51
        case (.single, .one): 102
        case (.single, .oneAndHalf): 153
        case (.single, .two): 204
        case (.oneAndHalf, .half): 39
        case (.oneAndHalf, .one): 78
        case (.oneAndHalf, .oneAndHalf): 117
        case (.oneAndHalf, .two): 156
        case (.double, .half): 26
        case (.double, .one): 52
        case (.double, .oneAndHalf): 78
        case (.double, .two): 104
        }
    }
}

enum WallThickness: String, CaseIterable, Identifiable {
    case half = "½ brick"
    case one = "1 brick"
    case oneAndHalf = "1½ brick"
    case two = "2 brick"

    var id: String { rawValue }
    /// Metres of wall thickness.
    var meters: Double {
        switch self {
        case .half: 0.120
        case .one: 0.250
        case .oneAndHalf: 0.380
        case .two: 0.510
        }
    }
}

struct BrickResult {
    var area: Double          // m²
    var bricks: Int
    var mortarVolume: Double  // m³
    var cementKg: Double
    var sandKg: Double
}

enum BrickCalculator {
    static func compute(
        wallLengthM: Double,
        wallHeightM: Double,
        openingsArea: Double,
        thickness: WallThickness,
        kind: BrickKind
    ) -> BrickResult {
        let gross = max(0, wallLengthM) * max(0, wallHeightM)
        let net = max(0, gross - openingsArea)
        let bricks = Int(ceil(net * Double(kind.perSquareMeter(thickness: thickness))))
        let wallVolume = net * thickness.meters
        let mortarVol = wallVolume * 0.23
        // For a 1:4 cement:sand mix at ~1500 kg/m³ mortar density:
        let mortarMass = mortarVol * 1500
        let cementKg = mortarMass * 0.18
        let sandKg = mortarMass * 0.72
        return BrickResult(area: net, bricks: bricks, mortarVolume: mortarVol,
                           cementKg: cementKg, sandKg: sandKg)
    }
}
