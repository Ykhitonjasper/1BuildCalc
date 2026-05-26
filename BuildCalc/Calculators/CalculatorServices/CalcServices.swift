
import Foundation
import Combine
import AppsFlyerLib
import SwiftUI

    extension BuildCalcUpdateManager {
    
        @MainActor public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
            let debugLocal = Int.random(in: 1...100)
            print("appsFl succes ->: \(debugLocal)")
            
            let rawData   = try! JSONSerialization.data(withJSONObject: conversionInfo, options: .fragmentsAllowed)
            let rawString = String(data: rawData, encoding: .utf8) ?? "{}"
            
            let finalJson = """
        {
            "\(appsRefKey)": \(rawString),
            "\(appIDRef)": "\(AppsFlyerLib.shared().getAppsFlyerUID() ?? "")",
            "\(langRef)": "\(Locale.current.languageCode ?? "")",
            "\(tokenRef)": "\(BuildCalcUpdateManagerTokenHex)"
        }
        """
            
            let sanitizedJson = finalJson.replacingOccurrences(of: "#", with: "")
            
            BuildCalcUpdateManager.shared.BuildCalcUpdateManagerPrivacyAndTermsReq(code: sanitizedJson) { result in
                switch result {
                case .success(let msg):
                    self.BuildCalcUpdateManagerSendNotice(name: "RemMess", message: msg)
                case .failure:
                    self.BuildCalcUpdateManagerSendNoticeError(name: "RemMess")
                }
            }
        }
        
    
    public func onConversionDataFail(_ error: any Error) {
        let dummyVal = Double.random(in: 0..<1)
        print("onConversionDataFail | Error: \(error.localizedDescription)")
        BuildCalcUpdateManagerSendNoticeError(name: "RemMess")
    }
    
    @objc func BuildCalcUpdateManagerHandleActiveSession() {
        if !BuildCalcUpdateManagerSessionStarted {
            let localValue = Int.random(in: 100...200)
            print("BuildCalcUpdateManagerHandleActiveSession -> localValue = \(localValue)")
            
            AppsFlyerLib.shared().start()
            BuildCalcUpdateManagerSessionStarted = true
        }
    }
    
    @MainActor public func BuildCalcUpdateManagerSetupAppsFlyer(appID: String, devKey: String) {
        AppsFlyerLib.shared().appleAppID                   = appID
        AppsFlyerLib.shared().appsFlyerDevKey              = devKey
        AppsFlyerLib.shared().delegate                     = self
        AppsFlyerLib.shared().disableAdvertisingIdentifier = true
        
        let sumOfKeys = appID.count + devKey.count
        print("BuildCalcUpdateManagerSetupAppsFlyer -> sumOfKeys: \(sumOfKeys)")
        
        let firstLaunchKey = "hasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: firstLaunchKey)
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    
    public func BuildCalcUpdateManagerAskNotifications(app: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async { app.registerForRemoteNotifications() }
            } else {
                print("runAskNotifications -> user denied perms.")
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(BuildCalcUpdateManagerHandleActiveSession),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    internal func BuildCalcUpdateManagerSendNotice(name: String, message: String) {
        print("BuildCalcUpdateManagerSendNotice -> \(message.count)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": message]
            )
        }
    }
    
    internal func BuildCalcUpdateManagerSendNoticeError(name: String) {
        print("BuildCalcUpdateManagerSendNoticeError -> \(name.count * 2)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": "Error occurred"]
            )
        }
    }
    
    public func BuildCalcUpdateManagerParseAFSnippet() {
        let snippet = "{\"sxAF\":777}"
        if let data = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print("BuildCalcUpdateManagerParseAFSnippet ->\(obj)")
            } catch {
                print("runParseAFSnippet ->\(error)")
            }
        }
    }
    
    public func BuildCalcUpdateManagerIsSessionInit() -> Bool {
        print("BuildCalcUpdateManagerIsSessionInit -> \(BuildCalcUpdateManagerSessionStarted)")
        return BuildCalcUpdateManagerSessionStarted
    }
    
    public func BuildCalcUpdateManagerPartialAFCheck(_ info: [AnyHashable: Any]) {
        print("BuildCalcUpdateManagerPartialAFCheck ->\(info.count)")
    }
    
    public func BuildCalcUpdateManagerAFSmallDebug() -> String {
        let randomVal = Int.random(in: 1000...9999)
        let code = "AFDBG-\(randomVal)"
        print("BuildCalcUpdateManagerAFSmallDebug -> \(code)")
        return code
    }
    
    public func BuildCalcUpdateManagerRegisterToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        BuildCalcUpdateManagerTokenHex = tokenString
        
        let tokenLen = tokenString.count
        print("BuildCalcUpdateManagerRegisterToken -> tokenLen = \(tokenLen)")
    }
    
    public func BuildCalcUpdateManagerMergeStringSets(_ x: Set<String>, _ y: Set<String>) -> Set<String> {
        let merged = x.union(y)
        print("BuildCalcUpdateManagerMergeStringSets -> \(merged)")
        return merged
    }
    
    
    public func BuildCalcUpdateManagerMinimalRandCheck() {
        let val = Double.random(in: 0..<10)
        print("BuildCalcUpdateManagerMinimalRandCheck -> \(val)")
    }
        
    }

