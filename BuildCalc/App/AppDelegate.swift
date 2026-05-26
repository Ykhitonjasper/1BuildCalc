
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        BuildCalcUpdateManager.shared.initApp(application: application, window: UIWindow()) { _ in }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DispatchQueue.main.async {
            BuildCalcUpdateManager.shared.BuildCalcUpdateManagerRegisterToken(deviceToken: deviceToken)
        }
    }
}
