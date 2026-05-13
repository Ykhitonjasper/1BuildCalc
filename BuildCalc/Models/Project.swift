import Foundation
import SwiftData

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var clientName: String
    var clientAddress: String
    var clientPhone: String
    var notes: String
    var taxPercent: Double
    var currencyCode: String
    var unitSystemRaw: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \LineItem.project)
    var lineItems: [LineItem] = []

    init(
        id: UUID = UUID(),
        name: String,
        clientName: String = "",
        clientAddress: String = "",
        clientPhone: String = "",
        notes: String = "",
        taxPercent: Double = 0,
        currencyCode: String = "USD",
        unitSystemRaw: String = "metric",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.clientName = clientName
        self.clientAddress = clientAddress
        self.clientPhone = clientPhone
        self.notes = notes
        self.taxPercent = taxPercent
        self.currencyCode = currencyCode
        self.unitSystemRaw = unitSystemRaw
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var subtotal: Double {
        lineItems.reduce(0) { $0 + $1.subtotal }
    }

    var taxAmount: Double {
        subtotal * (taxPercent / 100.0)
    }

    var total: Double {
        subtotal + taxAmount
    }

    var unitSystem: UnitSystem {
        UnitSystem(rawValue: unitSystemRaw) ?? .metric
    }
}
