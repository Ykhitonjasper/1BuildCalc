import SwiftUI

final class WallpaperCalcVM: ObservableObject {
    @Published var roomLength = ""
    @Published var roomWidth = ""
    @Published var roomHeight = ""
    @Published var rollLength = ""
    @Published var rollWidth = ""
    @Published var pricePerRoll = ""
    @Published var selectedPattern = Pattern.none
    @Published var openings: [Opening] = []

    enum Pattern: String, CaseIterable, Identifiable {
        case none = "No match"
        case straight = "Straight (0.3m)"
        case offset = "Offset (0.5m)"
        var id: String { rawValue }
        var waste: Double {
            switch self {
            case .none: 1.0
            case .straight: 1.15
            case .offset: 1.20
            }
        }
    }

    init() {
        rollLength = "10"
        rollWidth = "1.06"
    }

    var isValid: Bool {
        (Double(roomLength) ?? 0) > 0
            && (Double(roomWidth) ?? 0) > 0
            && (Double(roomHeight) ?? 0) > 0
    }

    var openingsAreaMetric: Double {
        openings.reduce(0) { $0 + $1.area }
    }

    func reset() {
        roomLength = ""; roomWidth = ""; roomHeight = ""; pricePerRoll = ""
        openings = []
    }
}
