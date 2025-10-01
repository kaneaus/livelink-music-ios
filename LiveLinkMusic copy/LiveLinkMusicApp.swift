import SwiftUI

@main
struct LiveLinkMusicApp: App {
    @StateObject private var locationManager = LocationManager()
    @State private var isFirstLaunch: Bool = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    
    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                SplashView()
                    .onAppear {
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    }
            } else if !UserDefaults.standard.bool(forKey: "hasCompletedLogin") {
                LoginView()
                    .environmentObject(locationManager)
            } else {
                ContentView()
                    .environmentObject(locationManager)
            }
        }
    }
}
