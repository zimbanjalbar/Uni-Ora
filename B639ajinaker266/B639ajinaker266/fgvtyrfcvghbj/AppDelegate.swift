import UIKit
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + k4yl53qz) {
            self.requestATTPermissionAndStartAppsFlyer()
        }
                
        return true
    }
    
    private func requestATTPermissionAndStartAppsFlyer() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + h0lubeyw) {
                    AppsFlyerLib.shared().appsFlyerDevKey = lj8o34z2
                    AppsFlyerLib.shared().appleAppID = sqyey5pt
                    AppsFlyerLib.shared().isDebug = false
                    AppsFlyerLib.shared().delegate = AppsFlyerManager.shared
                    
                    AppsFlyerLib.shared().start()
                    
                    if status == .authorized {
                        DispatchQueue.main.asyncAfter(deadline: .now() + vf5uk486) {
                            let isTrackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
                            if isTrackingEnabled {
                                AppsFlyerLib.shared().start()
                            }
                        }
                    }
                }
            }
        }
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
} 
