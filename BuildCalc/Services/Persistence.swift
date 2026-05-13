import Foundation
import SwiftData

enum Persistence {
    static let migrationKey = "didMigrateLegacyProjects_v1"
    static let seedKey = "didSeedMaterials_v1"

    static let schema = Schema([
        Material.self,
        Project.self,
        LineItem.self,
    ])

    static func makeContainer() -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Fallback: in-memory so the app still launches in dev
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }
    }

    /// One-time tasks on launch: migrate legacy UserDefaults projects, seed catalog.
    @MainActor
    static func bootstrap(container: ModelContainer) {
        let context = container.mainContext
        seedMaterialsIfNeeded(context: context)
        migrateLegacyProjectsIfNeeded(context: context)
    }

    @MainActor
    private static func seedMaterialsIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seedKey) else { return }
        for spec in MaterialSeed.defaults {
            context.insert(spec.makeMaterial())
        }
        try? context.save()
        UserDefaults.standard.set(true, forKey: seedKey)
    }

    @MainActor
    private static func migrateLegacyProjectsIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }
        defer { UserDefaults.standard.set(true, forKey: migrationKey) }

        guard let data = UserDefaults.standard.data(forKey: "saved_projects"),
              let legacy = try? JSONDecoder().decode([LegacySavedProject].self, from: data)
        else { return }

        for ls in legacy {
            let units = ls.unitSystem
            let currency = (units == "imperial") ? "USD" : "RUB"
            let p = Project(
                id: ls.id,
                name: ls.name,
                currencyCode: currency,
                unitSystemRaw: units,
                createdAt: ls.createdAt,
                updatedAt: ls.createdAt
            )
            context.insert(p)
            let item = LineItem(
                calculator: CalculatorKind(rawValue: ls.type.rawValue.lowercased()) ?? .area,
                title: ls.name,
                materialName: ls.materialName,
                materialUnit: ls.materialUnit,
                quantity: ls.quantity,
                unitPrice: ls.quantity > 0 ? ls.totalCost / ls.quantity : 0,
                subtotal: ls.totalCost,
                createdAt: ls.createdAt,
                project: p
            )
            context.insert(item)
        }
        try? context.save()
        UserDefaults.standard.removeObject(forKey: "saved_projects")
    }
}

/// Legacy v1 model — kept only for one-time migration from UserDefaults.
struct LegacySavedProject: Codable {
    var id: UUID
    var name: String
    var width: Double
    var height: Double
    var depth: Double
    var materialName: String
    var materialUnit: String
    var quantity: Double
    var totalCost: Double
    var type: LegacyType
    var createdAt: Date
    var unitSystem: String

    enum LegacyType: String, Codable {
        case area = "Area", volume = "Volume", wallpaper = "Wallpaper"
    }
}
