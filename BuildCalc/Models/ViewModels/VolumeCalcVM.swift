import SwiftUI

final class VolumeCalcVM: ObservableObject {
    @Published var length = ""
    @Published var width = ""
    @Published var depth = ""
    @Published var pricePerUnit = ""
    @Published var selected = MaterialPreset.all[5]
    @Published var wastePercent: Double = 0

    var volumeMetric: Double {
        let v = (Double(length) ?? 0) * (Double(width) ?? 0) * (Double(depth) ?? 0)
        return v * (1.0 + wastePercent / 100.0)
    }

    var isValid: Bool { volumeMetric > 0 }

    func reset() {
        length = ""; width = ""; depth = ""; pricePerUnit = ""; wastePercent = 0
    }
}
