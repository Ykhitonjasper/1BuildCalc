import Foundation

enum LaminateLayout: String, CaseIterable, Identifiable {
    case parallel = "Parallel"
    case diagonal = "Diagonal"
    var id: String { rawValue }
    var defaultWastePercent: Double { self == .parallel ? 5 : 10 }
}

struct LaminateResult {
    var floorArea: Double
    var boards: Int
    var packs: Int
    var underlayArea: Double
}

enum LaminateCalculator {
    static func compute(
        roomLengthM: Double,
        roomWidthM: Double,
        boardLengthMM: Double,
        boardWidthMM: Double,
        boardsPerPack: Int,
        layout: LaminateLayout,
        extraWastePercent: Double
    ) -> LaminateResult {
        let area = max(0, roomLengthM) * max(0, roomWidthM)
        let boardArea = max(0.0001, (boardLengthMM * boardWidthMM) / 1_000_000)
        let waste = 1.0 + (layout.defaultWastePercent + extraWastePercent) / 100.0
        let boards = Int(ceil(area * waste / boardArea))
        let packs = boardsPerPack > 0 ? Int(ceil(Double(boards) / Double(boardsPerPack))) : 0
        let underlay = area * 1.05
        return LaminateResult(floorArea: area, boards: boards, packs: packs, underlayArea: underlay)
    }
}
