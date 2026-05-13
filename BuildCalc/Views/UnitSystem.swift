import Foundation

enum UnitSystem: String, CaseIterable, Identifiable {
    case metric, imperial

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .metric: "Metric (m, cm)"
        case .imperial: "Imperial (ft, in)"
        }
    }

    var lengthUnit: String { self == .metric ? "m" : "ft" }
    var areaUnit: String { self == .metric ? "m²" : "ft²" }
    var volumeUnit: String { self == .metric ? "m³" : "ft³" }

    func fromMetric(_ m: Double) -> Double {
        self == .metric ? m : m * 3.281
    }
    func toMetric(_ v: Double) -> Double {
        self == .metric ? v : v / 3.281
    }
    func areaFromMetric(_ m2: Double) -> Double {
        self == .metric ? m2 : m2 * 10.764
    }
    func areaToMetric(_ v: Double) -> Double {
        self == .metric ? v : v / 10.764
    }
    func volumeFromMetric(_ m3: Double) -> Double {
        self == .metric ? m3 : m3 * 35.315
    }
    func volumeToMetric(_ v: Double) -> Double {
        self == .metric ? v : v / 35.315
    }

    func unit(for materialId: String) -> String {
        guard self != .metric else {
            return MaterialPreset.all.first { $0.id == materialId }?.unit ?? ""
        }
        switch materialId {
        case "brick", "tile": return "pcs"
        case "paint": return "gal"
        case "plaster": return "lb"
        case "laminate": return "ft²"
        case "concrete": return "ft³"
        default: return ""
        }
    }
}
