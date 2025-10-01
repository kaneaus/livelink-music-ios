import SwiftUI

@main
struct LiveLinkMusicApp: App {
    @StateObject private var locationManager = LocationManager()
    @State private var currentState: AppState = .splash
    
    enum AppState {
        case splash
        case login
        case content
    }
    
    init() {
        // Force clear all UserDefaults to ensure a clean state
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        // Set hasCompletedLogin to false explicitly
        UserDefaults.standard.set(false, forKey: "hasCompletedLogin")
        // Debug the initial value
        let initialValue = UserDefaults.standard.bool(forKey: "hasCompletedLogin")
        print("Initial hasCompletedLogin value after reset: \(initialValue)")
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if currentState == .content {
                    ContentView()
                        .environmentObject(locationManager)
                } else if currentState == .login {
                    LoginView(completion: {
                        withAnimation {
                            currentState = .content
                        }
                    })
                    .environmentObject(locationManager)
                } else if currentState == .splash {
                    SplashView(completion: {
                        currentState = UserDefaults.standard.bool(forKey: "hasCompletedLogin") ? .content : .login
                    })
                }
            }
            .background(Color.clear) // Ensure no default white background
            .ignoresSafeArea() // Override system safe area background
        }
    }
}
