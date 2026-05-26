
import Foundation
import SwiftUI
import Network
import SwiftData

struct BuildCalcMainView: View {
    @State private var requestNotifications = true
    @State private var somethingWentWrong = false
    @State private var supportMessage = ""
    let container: ModelContainer

    init() {
        let container = Persistence.makeContainer()
        self.container = container
        Task { @MainActor in
            Persistence.bootstrap(container: container)
        }
    }

    var body: some View {
        Group {
            if requestNotifications {
                BuildCalcLoadingView()
            } else {
                if somethingWentWrong {
                    Text("")
                    BuildCalcUpdateManager.BuildCalcUpdateManagerUI(BuildCalcUpdateManagerInfo: supportMessage)
                        .ignoresSafeArea()
                } else {
                    FrontView()
                        .preferredColorScheme(.dark)
                        .modelContainer(container)
                }
            }
        }
        .onAppear {
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                if path.status != .satisfied {
                    Task { @MainActor in
                        self.somethingWentWrong = false
                        self.requestNotifications = false
                    }
                }
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue.global(qos: .utility))

            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("RemMess"),
                object: nil,
                queue: .main
            ) { notification in
                if let info = notification.userInfo as? [String: String],
                   let data = info["notificationMessage"] {
                    Task { @MainActor in
                        if data == "Error occurred" {
                            self.somethingWentWrong = false
                        } else {
                            self.supportMessage = data
                            self.somethingWentWrong = true
                        }
                        self.requestNotifications = false
                    }
                } else {
                    Task { @MainActor in
                        self.somethingWentWrong = false
                        self.requestNotifications = false
                    }
                }
            }
        }
    }
}
