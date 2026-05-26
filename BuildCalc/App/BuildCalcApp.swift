import SwiftUI
import SwiftData

@main
struct BuildCalcApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            BuildCalcMainView()
                .preferredColorScheme(.dark)
        }
    }
}
