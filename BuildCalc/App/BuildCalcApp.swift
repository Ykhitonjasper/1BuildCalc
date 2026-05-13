import SwiftUI
import SwiftData

@main
struct BuildCalcApp: App {
    let container: ModelContainer

    init() {
        let container = Persistence.makeContainer()
        self.container = container
        Task { @MainActor in
            Persistence.bootstrap(container: container)
        }
    }

    var body: some Scene {
        WindowGroup {
            FrontView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
