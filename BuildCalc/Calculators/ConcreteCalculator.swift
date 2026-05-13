import Foundation

enum ConcreteGrade: String, CaseIterable, Identifiable {
    case m150, m200, m250, m300, m400

    var id: String { rawValue }
    var displayName: String { rawValue.uppercased() }

    /// Cement (kg) per m³ of finished concrete — typical Portland CEM I 42.5 figures.
    var cementPerM3: Double {
        switch self {
        case .m150: 220
        case .m200: 250
        case .m250: 300
        case .m300: 340
        case .m400: 410
        }
    }

    /// Sand kg per m³ — approximate from 1:2.8:4.4 / 1:2.5:4 / 1:2.1:3.9 / 1:1.9:3.7 / 1:1.4:3.1 mass ratios.
    var sandRatio: Double {
        switch self {
        case .m150: 2.8
        case .m200: 2.5
        case .m250: 2.1
        case .m300: 1.9
        case .m400: 1.4
        }
    }
    var gravelRatio: Double {
        switch self {
        case .m150: 4.4
        case .m200: 4.0
        case .m250: 3.9
        case .m300: 3.7
        case .m400: 3.1
        }
    }
}

enum RebarDiameter: String, CaseIterable, Identifiable {
    case none, d6, d8, d10, d12, d14, d16
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .none: "None"
        case .d6: "Ø6"
        case .d8: "Ø8"
        case .d10: "Ø10"
        case .d12: "Ø12"
        case .d14: "Ø14"
        case .d16: "Ø16"
        }
    }
    /// kg per linear metre — GOST 5781 standard mass.
    var kgPerMeter: Double {
        switch self {
        case .none: 0
        case .d6: 0.222
        case .d8: 0.395
        case .d10: 0.617
        case .d12: 0.888
        case .d14: 1.21
        case .d16: 1.58
        }
    }
}

struct ConcreteResult {
    var volume: Double      // m³
    var cement: Double      // kg
    var sand: Double        // kg
    var gravel: Double      // kg
    var water: Double       // L
    var rebarLength: Double // m
    var rebarMass: Double   // kg
}

enum ConcreteCalculator {
    /// All inputs in metres. `cellSize` is the mesh spacing in metres.
    static func compute(
        length: Double, width: Double, depth: Double,
        grade: ConcreteGrade,
        rebarD: RebarDiameter, cellSize: Double, layers: Int
    ) -> ConcreteResult {
        let L = max(0, length), W = max(0, width), D = max(0, depth)
        let volume = L * W * D
        let cement = volume * grade.cementPerM3
        let sand   = cement * grade.sandRatio
        let gravel = cement * grade.gravelRatio
        let water  = cement * 0.5

        var rebarLen = 0.0
        if rebarD != .none, cellSize > 0, L > 0, W > 0 {
            let barsAlongL = ceil(W / cellSize) + 1
            let barsAlongW = ceil(L / cellSize) + 1
            rebarLen = (barsAlongL * L + barsAlongW * W) * Double(max(1, layers))
        }
        let rebarMass = rebarLen * rebarD.kgPerMeter

        return ConcreteResult(volume: volume, cement: cement, sand: sand, gravel: gravel,
                              water: water, rebarLength: rebarLen, rebarMass: rebarMass)
    }
}
