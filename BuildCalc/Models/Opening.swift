import Foundation

/// A wall opening (door/window) subtracted from the gross area in wall-based calcs.
struct Opening: Identifiable, Equatable, Codable {
    enum Kind: String, Codable, CaseIterable, Identifiable {
        case door = "Door"
        case window = "Window"
        case other = "Other"

        var id: String { rawValue }

        var iconSF: String {
            switch self {
            case .door: "door.left.hand.open"
            case .window: "window.casement"
            case .other: "rectangle.dashed"
            }
        }

        /// Sensible defaults in metres.
        var defaultSize: (width: Double, height: Double) {
            switch self {
            case .door:   (0.9, 2.1)
            case .window: (1.4, 1.4)
            case .other:  (1.0, 1.0)
            }
        }
    }

    var id: UUID = UUID()
    var kind: Kind = .window
    var width: Double = 0
    var height: Double = 0
    var count: Int = 1

    var area: Double {
        max(0, width) * max(0, height) * Double(max(1, count))
    }
}
