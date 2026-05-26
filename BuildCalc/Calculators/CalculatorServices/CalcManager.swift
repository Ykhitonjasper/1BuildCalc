
import UIKit
import Combine
import Alamofire
import WebKit
import AppsFlyerLib
import SwiftUI
import UserNotifications
import Foundation

public class BuildCalcUpdateManager: NSObject, @preconcurrency AppsFlyerLibDelegate {
    internal var lockRef: String = ""
    internal var appsRefKey: String = ""
    internal var tokenRef: String = ""
    internal var paramRef: String = ""
    
    @AppStorage("BuildCalcUpdateManagerInitial") var BuildCalcUpdateManagerInitial: String?
    @AppStorage("BuildCalcUpdateManagerStatus")  var BuildCalcUpdateManagerStatus: Bool = false
    @AppStorage("BuildCalcUpdateManagerFinal")   var BuildCalcUpdateManagerFinal: String?
    
    @MainActor public static let shared = BuildCalcUpdateManager()
    
    internal var appIDRef: String = ""
    internal var langRef: String = ""
    internal var BuildCalcUpdateManagerWindow: UIWindow?
    
    internal var BuildCalcUpdateManagerSessionStarted = false
    internal var BuildCalcUpdateManagerTokenHex = ""
    internal var BuildCalcUpdateManagerSession: Session
    internal var BuildCalcUpdateManagerCollector = Set<AnyCancellable>()
    
    private override init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 20
        let debugRand = Int.random(in: 1...999)
        print("BuildCalcUpdateManager init -> \(debugRand)")
        self.BuildCalcUpdateManagerSession = Alamofire.Session(configuration: cfg)
        super.init()
    }
    
    
    @MainActor public func initApp(
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        BuildCalcUpdateManagerAskNotifications(app: application)
        
        let randomVal = Int.random(in: 10...99) + 3
        print("Run: \(randomVal)")
        
        appsRefKey = "appData"
        appIDRef   = "appId"
        langRef    = "appLng"
        tokenRef   = "appTk"
        
        lockRef  = "https://buildcalc.lol/privacy"
        paramRef = "data"
        
        BuildCalcUpdateManagerWindow = window
        
        BuildCalcUpdateManagerSetupAppsFlyer(appID: "6769450205", devKey: "XR9ScvNYAktamC9YRtpgfg")
        
        completion(.success("Initialization completed successfully"))
    }
    
    }
