import Foundation

/// Parser for mixed imperial/metric dimension strings.
///
/// Accepts the following forms:
///   - `1.5`         → 1.5 (raw decimal in current unit)
///   - `1.5 m`       → 1.5 m
///   - `150 cm`      → 1.5 m
///   - `1500 mm`     → 1.5 m
///   - `5'`          → 5 ft
///   - `5' 6"`       → 5.5 ft
///   - `5' 6 1/2"`   → 5.541666… ft
///   - `6 1/2"`      → 0.541666… ft (just inches)
///   - `6"`          → 0.5 ft
///   - `1/2`         → 0.5
enum ImperialFraction {

    /// Returns metres regardless of input form. `defaultUnit` is used when no unit hints are present.
    static func meters(_ raw: String, defaultUnit: UnitSystem) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        // Explicit metric unit suffixes
        if let v = stripMetric(trimmed) { return v }

        // Imperial parsing
        if trimmed.contains("'") || trimmed.contains("\"") {
            if let ft = parseFeetInches(trimmed) {
                return ft / 3.281
            }
            return nil
        }

        // Bare number or fraction
        if let v = parseNumber(trimmed) {
            return defaultUnit == .metric ? v : v / 3.281
        }

        return nil
    }

    /// Returns the value in the supplied unit system (m or ft).
    static func value(_ raw: String, in system: UnitSystem) -> Double? {
        guard let m = meters(raw, defaultUnit: system) else { return nil }
        return system == .metric ? m : m * 3.281
    }

    // MARK: - Helpers

    private static func stripMetric(_ s: String) -> Double? {
        let lower = s.lowercased()
        let suffixes: [(String, Double)] = [
            ("mm", 0.001), ("cm", 0.01), ("m", 1.0),
        ]
        for (suffix, multiplier) in suffixes {
            if lower.hasSuffix(suffix) {
                let numberPart = lower.dropLast(suffix.count).trimmingCharacters(in: .whitespaces)
                if let v = parseNumber(String(numberPart)) {
                    return v * multiplier
                }
            }
        }
        return nil
    }

    private static func parseFeetInches(_ s: String) -> Double? {
        var feet: Double = 0
        var inches: Double = 0
        var rest = s

        if let feetRange = rest.range(of: "'") {
            let feetPart = rest[..<feetRange.lowerBound].trimmingCharacters(in: .whitespaces)
            if let f = parseNumber(String(feetPart)) {
                feet = f
            } else {
                return nil
            }
            rest = String(rest[feetRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        }

        if rest.hasSuffix("\"") {
            let inchPart = String(rest.dropLast()).trimmingCharacters(in: .whitespaces)
            if !inchPart.isEmpty {
                if let i = parseNumber(inchPart) {
                    inches = i
                } else {
                    return nil
                }
            }
        } else if !rest.isEmpty {
            // Trailing inches without explicit `"` — accept.
            if let i = parseNumber(rest) {
                inches = i
            } else {
                return nil
            }
        }

        return feet + inches / 12.0
    }

    /// Parses `1.5`, `1/2`, or `5 1/2` into a Double.
    private static func parseNumber(_ s: String) -> Double? {
        let t = s.trimmingCharacters(in: .whitespaces)
        if t.isEmpty { return nil }
        let parts = t.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        if parts.count == 2 {
            guard let whole = Double(parts[0]), let frac = fraction(parts[1]) else { return nil }
            return whole + frac
        }
        if let frac = fraction(t) { return frac }
        return Double(t)
    }

    private static func fraction(_ s: String) -> Double? {
        let parts = s.split(separator: "/").map(String.init)
        guard parts.count == 2,
              let num = Double(parts[0]),
              let den = Double(parts[1]),
              den != 0 else { return nil }
        return num / den
    }
}
