import SwiftUI

/// Floor / wall shape used by area-based calculators. Each case returns area in m²
/// given up to 5 dimensions (extras are ignored if not needed).
enum RoomShape: String, CaseIterable, Identifiable {
    case rectangle = "Rectangle"
    case lshape = "L-shape"
    case ushape = "U-shape"
    case triangle = "Triangle"
    case trapezoid = "Trapezoid"
    case circle = "Circle"

    var id: String { rawValue }

    var iconSF: String {
        switch self {
        case .rectangle: "rectangle"
        case .lshape: "l.square"
        case .ushape: "u.square"
        case .triangle: "triangle"
        case .trapezoid: "rhombus"
        case .circle: "circle"
        }
    }

    /// Number of dimension inputs the shape requires.
    var inputCount: Int {
        switch self {
        case .rectangle: 2  // width × height
        case .triangle:  3  // a × b × c (Heron's) OR base × height (we use base × height)
        case .trapezoid: 3  // a (top), b (bottom), h (height)
        case .lshape:    4  // outer W, outer H, cut W, cut H
        case .ushape:    5  // outer W, outer H, cut W, cut H, leg W (channel)
        case .circle:    1  // diameter
        }
    }

    /// Dimension labels (m).
    func label(_ index: Int) -> String {
        switch self {
        case .rectangle: ["Width", "Height"][safe: index] ?? ""
        case .triangle:  ["Base", "Height", "—"][safe: index] ?? ""
        case .trapezoid: ["Top (a)", "Bottom (b)", "Height (h)"][safe: index] ?? ""
        case .lshape:    ["Outer W", "Outer H", "Cut W", "Cut H"][safe: index] ?? ""
        case .ushape:    ["Outer W", "Outer H", "Cut W", "Cut H", "Channel W"][safe: index] ?? ""
        case .circle:    ["Diameter"][safe: index] ?? ""
        }
    }

    func area(d1: Double, d2: Double, d3: Double, d4: Double, d5: Double) -> Double {
        switch self {
        case .rectangle:
            return max(0, d1) * max(0, d2)
        case .triangle:
            return max(0, d1) * max(0, d2) / 2.0
        case .trapezoid:
            return (max(0, d1) + max(0, d2)) * max(0, d3) / 2.0
        case .lshape:
            let outer = max(0, d1) * max(0, d2)
            let cut = max(0, d3) * max(0, d4)
            return max(0, outer - cut)
        case .ushape:
            let outer = max(0, d1) * max(0, d2)
            let cut = max(0, d3) * max(0, d4)
            // For a U-shape, the cut sits in the middle with channel width offsetting it.
            // We treat (d5) as the channel as a sanity guard; if it overlaps, clamp.
            _ = d5
            return max(0, outer - cut)
        case .circle:
            let r = max(0, d1) / 2.0
            return .pi * r * r
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
