import SwiftUI

final class AreaCalcVM: ObservableObject {
    @Published var width = ""
    @Published var height = ""
    @Published var pricePerUnit = ""
    @Published var selected = MaterialPreset.all[0]
    @Published var wastePercent: Double = 0
    @Published var openings: [Opening] = []
    @Published var shape: RoomShape = .rectangle
    @Published var dim2: String = ""  // secondary dim for L/U/Triangle/Trapezoid
    @Published var dim3: String = ""
    @Published var dim4: String = ""

    /// Net area in metric (m²) — applies shape, then subtracts openings, then applies waste.
    var areaMetric: Double {
        let base = shape.area(
            d1: Double(width) ?? 0,
            d2: Double(height) ?? 0,
            d3: Double(dim2) ?? 0,
            d4: Double(dim3) ?? 0,
            d5: Double(dim4) ?? 0
        )
        let openingsArea = openings.reduce(0) { $0 + $1.area }
        let net = max(0, base - openingsArea)
        return net * (1.0 + wastePercent / 100.0)
    }

    var grossAreaMetric: Double {
        shape.area(
            d1: Double(width) ?? 0,
            d2: Double(height) ?? 0,
            d3: Double(dim2) ?? 0,
            d4: Double(dim3) ?? 0,
            d5: Double(dim4) ?? 0
        )
    }

    var openingsAreaMetric: Double {
        openings.reduce(0) { $0 + $1.area }
    }

    var isValid: Bool { areaMetric > 0 }

    func reset() {
        width = ""; height = ""; pricePerUnit = ""
        dim2 = ""; dim3 = ""; dim4 = ""
        wastePercent = 0
        openings = []
        shape = .rectangle
    }
}
