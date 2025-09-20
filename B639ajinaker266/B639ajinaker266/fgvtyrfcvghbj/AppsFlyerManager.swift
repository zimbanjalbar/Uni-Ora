import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {
    static let shared = AppsFlyerManager()
    private var eubezt44 = false
    private var ew1747rc: ((String?) -> Void)?

    func e6ao96fo(completion: @escaping (String?) -> Void) {
        self.ew1747rc = completion

        DispatchQueue.main.asyncAfter(deadline: .now() + jdtg2z7s) {
            self.forceUpdateATTStatus()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + dcw8mzf6) {
            if !self.eubezt44 {
                self.ew1747rc?(nil)
            }
        }
    }

    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        if let campaign = data["campaign"] as? String {
            let components = campaign.split(separator: "_")
            var parameters = ""
            for (index, value) in components.enumerated() {
                parameters += "sub\(index + 1)=\(value)"
                if index < components.count - 1 {
                    parameters += "&"
                }
            }
            eubezt44 = true
            ew1747rc?("&" + parameters)
        } else {
            eubezt44 = true
            ew1747rc?(nil)
        }
    }

    func onConversionDataFail(_ error: Error) {
        ew1747rc?(nil)
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        if let campaign = attributionData["campaign"] as? String {
            let components = campaign.split(separator: "_")
            var parameters = ""
            for (index, value) in components.enumerated() {
                parameters += "sub\(index + 1)=\(value)"
                if index < components.count - 1 {
                    parameters += "&"
                }
            }
            eubezt44 = true
            ew1747rc?("&" + parameters)
        }
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        ew1747rc?(nil)
    }
    
    private func forceUpdateATTStatus() {
        let currentStatus = ATTrackingManager.trackingAuthorizationStatus
        
        if currentStatus == .authorized {
            AppsFlyerLib.shared().start()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + vf5uk486) {
                let isTrackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
                if isTrackingEnabled {
                    AppsFlyerLib.shared().start()
                }
            }
        }
    }
} 
