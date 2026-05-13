import Foundation

enum Currency: String, CaseIterable, Identifiable, Codable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case rub = "RUB"
    case cad = "CAD"
    case aud = "AUD"
    case jpy = "JPY"
    case cny = "CNY"
    case inr = "INR"
    case brl = "BRL"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .usd, .cad, .aud: "$"
        case .eur: "€"
        case .gbp: "£"
        case .rub: "₽"
        case .jpy, .cny: "¥"
        case .inr: "₹"
        case .brl: "R$"
        }
    }

    var displayName: String {
        switch self {
        case .usd: "US Dollar"
        case .eur: "Euro"
        case .gbp: "British Pound"
        case .rub: "Russian Ruble"
        case .cad: "Canadian Dollar"
        case .aud: "Australian Dollar"
        case .jpy: "Japanese Yen"
        case .cny: "Chinese Yuan"
        case .inr: "Indian Rupee"
        case .brl: "Brazilian Real"
        }
    }

    static func from(code: String) -> Currency {
        Currency(rawValue: code) ?? .usd
    }

    static func format(_ value: Double, code: String, fractionDigits: Int = 2) -> String {
        let cur = Currency.from(code: code)
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.groupingSeparator = " "
        formatter.usesGroupingSeparator = true
        let n = formatter.string(from: NSNumber(value: value)) ?? "0"
        return "\(n) \(cur.symbol)"
    }
}
