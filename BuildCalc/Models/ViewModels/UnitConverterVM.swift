import SwiftUI

final class UnitConverterVM: ObservableObject {
    @Published var inputValue = "100"
    @Published var selectedCategory = Category.area
    @Published var fromUnit = UnitItem.metricArea[0]
    @Published var toUnit = UnitItem.metricArea[1]

    enum Category: String, CaseIterable, Identifiable {
        case area = "Area"
        case length = "Length"
        case volume = "Volume"
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .area: "square.split.bottomrightquarter"
            case .length: "ruler"
            case .volume: "cube"
            }
        }
    }

    struct UnitItem: Identifiable, Hashable {
        let id: String
        let name: String
        let factor: Double
        static let metricArea = [
            UnitItem(id: "m2",  name: "m²", factor: 1),
            UnitItem(id: "ft2", name: "ft²", factor: 10.764),
            UnitItem(id: "ac",  name: "ac",  factor: 0.000247),
            UnitItem(id: "ha",  name: "ha",  factor: 0.0001)
        ]
        static let metricLength = [
            UnitItem(id: "m",  name: "m",  factor: 1),
            UnitItem(id: "ft", name: "ft", factor: 3.281),
            UnitItem(id: "cm", name: "cm", factor: 100),
            UnitItem(id: "in", name: "in", factor: 39.37)
        ]
        static let metricVolume = [
            UnitItem(id: "m3",  name: "m³",  factor: 1),
            UnitItem(id: "l",   name: "L",   factor: 1000),
            UnitItem(id: "ft3", name: "ft³", factor: 35.315),
            UnitItem(id: "gal", name: "gal", factor: 264.2)
        ]
    }

    var result: String {
        let v = Double(inputValue) ?? 0
        let c = v / fromUnit.factor * toUnit.factor
        return String(format: "%.4f", c)
    }

    var units: [UnitItem] {
        switch selectedCategory {
        case .area: UnitItem.metricArea
        case .length: UnitItem.metricLength
        case .volume: UnitItem.metricVolume
        }
    }

    func syncUnits() {
        let u = units
        if !u.contains(fromUnit) { fromUnit = u[0] }
        if !u.contains(toUnit)   { toUnit   = u[1] }
    }
}
