import Foundation

struct TileResult {
    var area: Double           // m² (net, with waste applied)
    var tileCount: Int
    var adhesiveKg: Double
    var adhesiveBags: Int      // 25 kg bags
    var groutKg: Double
}

enum TileCalculator {
    /// `area` is the gross wall/floor area in m². `openingsArea` is subtracted.
    static func compute(
        area: Double,
        openingsArea: Double,
        tileWidthMM: Double,
        tileHeightMM: Double,
        gapMM: Double,
        adhesiveKgPerM2: Double,
        wastePercent: Double
    ) -> TileResult {
        let net = max(0, area - openingsArea)
        let waste = 1.0 + max(0, wastePercent) / 100.0
        let effW = max(1, tileWidthMM + gapMM) / 1000.0
        let effH = max(1, tileHeightMM + gapMM) / 1000.0
        let tileArea = effW * effH
        let tileCount = tileArea > 0 ? Int(ceil(net / tileArea * waste)) : 0

        let adhesiveKg = net * adhesiveKgPerM2 * waste
        let adhesiveBags = adhesiveKg > 0 ? Int(ceil(adhesiveKg / 25.0)) : 0

        // Grout (approximate, kg). Empirical: groutKg ≈ area × (tileW+tileH)×gap / (tileW×tileH) × density(1.6 g/cm³ → 1.6 kg/L)×thickness ratio.
        // Simplified rule: 0.5 kg/m² baseline × gap/2 mm × 600×600/(tileW×tileH adjusted).
        let perimeterFactor = (tileWidthMM + tileHeightMM)
        let areaFactor = (tileWidthMM * tileHeightMM)
        let groutPerM2 = areaFactor > 0 ? perimeterFactor * gapMM * 0.0016 / areaFactor * 1_000_000 / 1000 : 0
        let groutKg = max(0.1, groutPerM2) * net * waste

        return TileResult(
            area: net * waste,
            tileCount: tileCount,
            adhesiveKg: adhesiveKg,
            adhesiveBags: adhesiveBags,
            groutKg: groutKg
        )
    }
}
