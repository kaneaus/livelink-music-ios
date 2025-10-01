import SwiftUI

struct LinksView: View {
    @Binding var currentScreen: ContentView.Screen

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderView(
                    isMapView: false,
                    switchToMap: { currentScreen = .map },
                    switchToList: { currentScreen = .list }
                )
                Text("Linked Artists and Venues")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                Text("This screen will show artists and venues you are linked with, along with upcoming event notifications.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
                BottomMenuBar(currentScreen: $currentScreen)
            }
        }
    }
}

struct GigsView: View {
    @Binding var currentScreen: ContentView.Screen

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderView(
                    isMapView: false,
                    switchToMap: { currentScreen = .map },
                    switchToList: { currentScreen = .list }
                )
                Text("Upcoming Events")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                Text("This screen will show upcoming events for artists.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
                BottomMenuBar(currentScreen: $currentScreen)
            }
        }
    }
}

struct ProfileView: View {
    @Binding var currentScreen: ContentView.Screen

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderView(
                    isMapView: false,
                    switchToMap: { currentScreen = .map },
                    switchToList: { currentScreen = .list }
                )
                Text("Profile")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                Text("This screen will allow users to change settings and manage their profile.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
                BottomMenuBar(currentScreen: $currentScreen)
            }
        }
    }
}
