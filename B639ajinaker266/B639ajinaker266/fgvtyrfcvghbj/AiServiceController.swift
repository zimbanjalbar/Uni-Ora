import SwiftUI
import WebKit
import UserNotifications

class vvcw0cxo: ObservableObject {
    @Published var webView: WKWebView?
    @Published var canGoBack = false
    @Published var ypat7ri1: [WKWebView] = []
    
    func j2q9ug9l(_ webView: WKWebView) {
        self.webView = webView
        g1at2204()
    }
    
    func g1at2204() {
        let activeWebView = w6sq68yy()
        canGoBack = activeWebView.canGoBack || !ypat7ri1.isEmpty
    }
    
    func goBack() {
        let activeWebView = w6sq68yy()
        
        if activeWebView.canGoBack {
            activeWebView.goBack()
        } else if !ypat7ri1.isEmpty {
            if let lastOverlay = ypat7ri1.last {
                mqc4o7j2(lastOverlay)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.g1at2204()
        }
    }
    
    func d047tigg(to url: URL) {
        ypat7ri1.removeAll()
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        webView?.load(request)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.g1at2204()
        }
    }
    
    func btn2ztki(_ webView: WKWebView) {
        ypat7ri1.append(webView)
        g1at2204()
    }
    
    func mqc4o7j2(_ webView: WKWebView) {
        ypat7ri1.removeAll { $0 === webView }
        g1at2204()
    }
    
    private func w6sq68yy() -> WKWebView {
        return ypat7ri1.last ?? webView ?? WKWebView()
    }
}

struct lugeoo7r: View {
    let url: URL
    let ozux49zo: kxt34b2q
    let i2pjh1x9: ((URL) -> Void)?
    
    @StateObject private var tngfv34v = vvcw0cxo()

    init(url: URL, ozux49zo: kxt34b2q = .none, i2pjh1x9: ((URL) -> Void)? = nil) {
        self.url = url
        self.ozux49zo = ozux49zo
        self.i2pjh1x9 = i2pjh1x9
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                vl9khzlv(url: url, i2pjh1x9: i2pjh1x9, tngfv34v: tngfv34v)
                
                ForEach(Array(tngfv34v.ypat7ri1.enumerated()), id: \.offset) { index, overlayWebView in
                    knz7y0w9(webView: overlayWebView, tngfv34v: tngfv34v)
                }
            }
            
            if ozux49zo != .none {
                yqlgsv3v(ozux49zo: ozux49zo, tngfv34v: tngfv34v, or6ek9by: url)
            }
        }
    }
}

struct vl9khzlv: UIViewRepresentable {
    let url: URL
    let i2pjh1x9: ((URL) -> Void)?
    let tngfv34v: vvcw0cxo

    init(url: URL, i2pjh1x9: ((URL) -> Void)? = nil, tngfv34v: vvcw0cxo) {
        self.url = url
        self.i2pjh1x9 = i2pjh1x9
        self.tngfv34v = tngfv34v
    }

    func makeUIView(context: Context) -> UIView {
        requestNotificationPermission()
        let config = WKWebViewConfiguration()
        
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        if #available(iOS 14.0, *) {
            config.limitsNavigationsToAppBoundDomains = false
        }
        
        config.preferences.isFraudulentWebsiteWarningEnabled = false
        config.suppressesIncrementalRendering = false
        
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        config.allowsAirPlayForMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.overrideUserInterfaceStyle = .dark
        webView.allowsBackForwardNavigationGestures = false // Отключаем для единообразия
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        webView.load(request)
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        containerView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: containerView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        let swipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(yt73fap2.skach72s(_:)))
        swipeGesture.direction = .right
        containerView.addGestureRecognizer(swipeGesture)
        
        DispatchQueue.main.async {
            tngfv34v.j2q9ug9l(webView)
        }
        
        return containerView
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Ошибка при запросе разрешения: \(error.localizedDescription)")
                return
            }
        }
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

    func makeCoordinator() -> yt73fap2 {
        yt73fap2(i2pjh1x9: i2pjh1x9, tngfv34v: tngfv34v)
    }
}

struct yqlgsv3v: View {
    let ozux49zo: kxt34b2q
    @ObservedObject var tngfv34v: vvcw0cxo
    let or6ek9by: URL
    
    init(ozux49zo: kxt34b2q, tngfv34v: vvcw0cxo, or6ek9by: URL) {
        self.ozux49zo = ozux49zo
        self.tngfv34v = tngfv34v
        self.or6ek9by = or6ek9by
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                tngfv34v.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(tngfv34v.canGoBack ? .white : .gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .disabled(!tngfv34v.canGoBack)
            
            if ozux49zo == .nt21zn4r {
                // Разделитель
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1)
                
                // Кнопка домой
                Button(action: {
                    tngfv34v.d047tigg(to: or6ek9by)
                }) {
                    Image(systemName: "house")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .background(Color.black)
        .frame(height: 50)
        .background(Color.black) 
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension vl9khzlv {
    class yt73fap2: NSObject, WKNavigationDelegate, WKUIDelegate {
        let i2pjh1x9: ((URL) -> Void)?
        private var l8l2ck90 = false
        weak var tngfv34v: vvcw0cxo?

        init(i2pjh1x9: ((URL) -> Void)? = nil, tngfv34v: vvcw0cxo) {
            self.i2pjh1x9 = i2pjh1x9
            self.tngfv34v = tngfv34v
        }
        
        @objc func skach72s(_ gesture: UISwipeGestureRecognizer) {
            tngfv34v?.goBack()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if !l8l2ck90, let currentURL = webView.url {
                l8l2ck90 = true
                i2pjh1x9?(currentURL)
            }
            
            DispatchQueue.main.async {
                self.tngfv34v?.g1at2204()
            }
        }
        


        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url {
                let scheme = url.scheme?.lowercased() ?? ""
                
                if scheme == "about" {
                    decisionHandler(.allow)
                    return
                }
                
                if url.host?.contains("challenges.cloudflare.com") == true {
                    decisionHandler(.allow)
                    return
                }
                
                if ["http", "https"].contains(scheme) {
                    decisionHandler(.allow)
                } else if ["tel", "mailto", "sms"].contains(scheme) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.allow)
            }
        }

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            let overlayWebView = WKWebView(frame: .zero, configuration: configuration)
            overlayWebView.navigationDelegate = self
            overlayWebView.uiDelegate = self
            overlayWebView.overrideUserInterfaceStyle = .dark
            overlayWebView.allowsBackForwardNavigationGestures = false
            overlayWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            
            DispatchQueue.main.async {
                self.tngfv34v?.btn2ztki(overlayWebView)
                
                var request = navigationAction.request
                request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
                overlayWebView.load(request)
            }
            
            return overlayWebView
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.text = defaultText
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(nil)
            })
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(alert.textFields?.first?.text)
            })
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
    }
}

struct knz7y0w9: UIViewRepresentable {
    let webView: WKWebView
    let tngfv34v: vvcw0cxo
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .black.withAlphaComponent(0.95)
        
        containerView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: containerView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        let swipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(myp4ottq.skach72s(_:)))
        swipeGesture.direction = .right
        containerView.addGestureRecognizer(swipeGesture)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(myp4ottq.buhnyln6(_:)))
        tapGesture.numberOfTapsRequired = 2
        containerView.addGestureRecognizer(tapGesture)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    func makeCoordinator() -> myp4ottq {
        myp4ottq(webView: webView, tngfv34v: tngfv34v)
    }
}

class myp4ottq: NSObject {
    let webView: WKWebView
    let tngfv34v: vvcw0cxo
    
    init(webView: WKWebView, tngfv34v: vvcw0cxo) {
        self.webView = webView
        self.tngfv34v = tngfv34v
    }
    
    @objc func skach72s(_ gesture: UISwipeGestureRecognizer) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            tngfv34v.mqc4o7j2(webView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tngfv34v.g1at2204()
        }
    }
    
    @objc func buhnyln6(_ gesture: UITapGestureRecognizer) {
        tngfv34v.mqc4o7j2(webView)
    }
}
