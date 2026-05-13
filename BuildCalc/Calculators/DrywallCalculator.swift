import Foundation

struct DrywallResult {
    var area: Double            // m² of finished surface
    var sheets: Int
    var udProfileMeters: Double
    var cdProfileMeters: Double
    var screws: Int
    var puttyKg: Double
    var jointTapeMeters: Double
}

enum DrywallCalculator {
    static func compute(
        area: Double,
        openingsArea: Double,
        sheetWidthM: Double,
        sheetHeightM: Double,
        layers: Int,
        wastePercent: Double,
        perimeterM: Double
    ) -> DrywallResult {
        let net = max(0, area - openingsArea)
        let waste = 1.0 + max(0, wastePercent) / 100.0
        let sheetArea = max(0.01, sheetWidthM * sheetHeightM)
        let sheets = Int(ceil(net * Double(max(1, layers)) / sheetArea * waste))
        let ud = perimeterM                       // ceiling+floor UD around the wall
        let cd = net * 2.0                        // ~600mm centers
        let screws = Int(ceil(net * 25.0 * Double(layers)))
        let putty = net * 1.2
        let tape = net * 1.5
        return DrywallResult(area: net, sheets: sheets,
                             udProfileMeters: ud, cdProfileMeters: cd,
                             screws: screws, puttyKg: putty, jointTapeMeters: tape)
    }
}
