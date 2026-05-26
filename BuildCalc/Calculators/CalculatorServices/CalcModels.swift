
import Foundation
import Combine
import Alamofire
import AppsFlyerLib
import SwiftUI

    extension BuildCalcUpdateManager {
    
    public func BuildCalcUpdateManagerPrivacyAndTermsReq(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let debugLocalRand = code.count + Int.random(in: 1...30)
        print("runCheckDataFlow -> \(debugLocalRand)")
        
        let parameters = [paramRef: code]
        BuildCalcUpdateManagerSession.request(lockRef, method: .get, parameters: parameters)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let htmlResponse):
                    
                    guard let base64Res = self.extractBase64(from: htmlResponse) else {
                        completion(.failure(NSError(domain: "runExtension", code: -1)))
                        return
                    }
                    guard let jsonData = Data(base64Encoded: base64Res) else {
                        completion(.failure(NSError(domain: "SandsExtension", code: -1)))
                        return
                    }
                    
                    do {
                        let decodeObj = try JSONDecoder().decode(BuildCalcUpdateManagerResponse.self, from: jsonData)
                        
                        self.BuildCalcUpdateManagerStatus = decodeObj.first_link
                        
                        if self.BuildCalcUpdateManagerInitial == nil {
                            self.BuildCalcUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else if decodeObj.link == self.BuildCalcUpdateManagerInitial {
                            completion(.success(self.BuildCalcUpdateManagerFinal ?? decodeObj.link))
                        } else if self.BuildCalcUpdateManagerStatus {
                            self.BuildCalcUpdateManagerFinal   = nil
                            self.BuildCalcUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else {
                            self.BuildCalcUpdateManagerInitial = decodeObj.link
                            completion(.success(self.BuildCalcUpdateManagerFinal ?? decodeObj.link))
                        }
                        
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    public func BuildCalcUpdateManagerLocalMathCompute(_ x: Int) -> Int {
        let result = (x * 4) - 2
        print("BuildCalcUpdateManagerLocalMathCompute -> base \(x), result \(result)")
        return result
    }
    
    func extractBase64(from html: String) -> String? {
        let pattern = #"<p\s+style="display:none;">([^<]+)</p>"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            if let match = regex.firstMatch(in: html, options: [], range: range),
               match.numberOfRanges > 1,
               let captureRange = Range(match.range(at: 1), in: html) {
                return String(html[captureRange])
            }
        } catch {
            print("extractBase64 -> Regex error: \(error)")
        }
        return nil
    }
    
    public func DoubleToLine(_ arr: [Double]) -> String {
        let line = arr.map { String($0) }.joined(separator: ",")
        print("runDoubleToLine -> \(line)")
        return line
    }
    
    public struct BuildCalcUpdateManagerResponse: Codable {
        var link:       String
        var naming:     String
        var first_link: Bool
    }
    
    public func BuildCalcUpdateManagerParseNetSnippet() {
        let snippet = "{\"sxNet\":555}"
        if let d = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed)
                print("BuildCalcUpdateManagerParseNetSnippet -> keys: \(obj)")
            } catch {
                print("runParseNetSnippet -> error: \(error)")
            }
        }
    }
    
    public func BuildCalcUpdateManagerPartialNetInspect(_ info: [String: Any]) {
        print("BuildCalcUpdateManagerPartialNetInspect -> keys: \(info.keys.count)")
    }
    
    public struct BuildCalcUpdateManagerUI: UIViewControllerRepresentable {
        
        public var BuildCalcUpdateManagerInfo: String
        
        public init(BuildCalcUpdateManagerInfo: String) {
            self.BuildCalcUpdateManagerInfo = BuildCalcUpdateManagerInfo
        }
        
        public func makeUIViewController(context: Context) -> BuildCalcUpdateManagerSceneController {
            let ctrl = BuildCalcUpdateManagerSceneController()
            ctrl.fruitErrorURL = BuildCalcUpdateManagerInfo
            return ctrl
        }
        
        public func updateUIViewController(_ uiViewController: BuildCalcUpdateManagerSceneController, context: Context) { }
    }
    
    
    public func BuildCalcUpdateManagerReverseSwiftText(_ text: String) -> String {
        let reversed = String(text.reversed())
        print("runReverseSwiftText -> Original: \(text), reversed: \(reversed)")
        return reversed
    }
    
    public func BuildCalcUpdateManagerDelayUIUpdate(secs: Double) {
        print("runDelayUIUpdate -> scheduling in \(secs) s.")
        DispatchQueue.main.asyncAfter(deadline: .now() + secs) {
            print("runDelayUIUpdate -> done.")
        }
    }
    
    @MainActor public func showView(with url: String) {
        self.BuildCalcUpdateManagerWindow = UIWindow(frame: UIScreen.main.bounds)
        let scn = BuildCalcUpdateManagerSceneController()
        scn.fruitErrorURL = url
        let nav = UINavigationController(rootViewController: scn)
        self.BuildCalcUpdateManagerWindow?.rootViewController = nav
        self.BuildCalcUpdateManagerWindow?.makeKeyAndVisible()
        
        let sceneDbg = Int.random(in: 1...50)
        print("showView -> sceneDbg = \(sceneDbg)")
    }
    
    public func BuildCalcUpdateManagerCheckCasePalindrome(_ text: String) -> Bool {
        let lower = text.lowercased()
        let reversed = String(lower.reversed())
        let result = (lower == reversed)
        print("runCheckCasePalindrome -> \(text): \(result)")
        return result
    }
    
    public func BuildCalcUpdateManagerBuildRandomConfig() -> [String: Any] {
        let config = ["mode": "testSands",
                      "active": Bool.random(),
                      "index": Int.random(in: 1...200)] as [String : Any]
        print("runBuildRandomConfig -> \(config)")
        return config
    }
    }

