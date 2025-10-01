import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var eventService = EventService()
    @StateObject private var mapService = MapService()
    @StateObject private var locationManager = LocationManager()
    @State private var filteredEvents: [EventAccepted] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedEvent: EventAccepted?
    @State private var searchText: String = ""
    @State private var showFilterSheet: Bool = false
    @State private var selectedCategory: String = "All"
    @State private var currentScreen: Screen = .map
    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: "hasCompletedLogin")

    indirect enum Screen: Equatable {
        case map
        case list
        case eventDetails(EventAccepted, Screen)
        case links
        case gigs
        case profile
        static func == (lhs: Screen, rhs: Screen) -> Bool {
            switch (lhs, rhs) {
            case (.map, .map), (.list, .list), (.links, .links), (.gigs, .gigs), (.profile, .profile):
                return true
            case let (.eventDetails(event1, _), .eventDetails(event2, _)):
                return event1.id == event2.id
            default:
                return false
            }
        }
    }

    var body: some View {
        if isLoggedIn {
            ZStack {
                switch currentScreen {
                case .map:
                    MapView(
                        eventService: eventService,
                        mapService: mapService,
                        locationManager: locationManager,
                        filteredEvents: $filteredEvents,
                        region: $region,
                        selectedEvent: $selectedEvent,
                        searchText: $searchText,
                        showFilterSheet: $showFilterSheet,
                        selectedCategory: $selectedCategory,
                        currentScreen: $currentScreen,
                        applyFilters: applyFilters(to:)
                    )
                case .list:
                    ListView(
                        eventService: eventService,
                        filteredEvents: $filteredEvents,
                        selectedEvent: $selectedEvent,
                        searchText: $searchText,
                        showFilterSheet: $showFilterSheet,
                        selectedCategory: $selectedCategory,
                        currentScreen: $currentScreen,
                        applyFilters: applyFilters(to:)
                    )
                case .eventDetails(let event, let previousScreen):
                    EventDetailsView(
                        event: event,
                        previousScreen: previousScreen,
                        currentScreen: $currentScreen
                    )
                case .links:
                    LinksView(
                        currentScreen: $currentScreen
                    )
                case .gigs:
                    GigsView(
                        currentScreen: $currentScreen
                    )
                case .profile:
                    ProfileView(
                        currentScreen: $currentScreen
                    )
                }
            }
            .onAppear {
                Task {
                    await eventService.fetchEvents(userLocation: locationManager.userLocation)
                }
                print("ContentView loaded with isLoggedIn: \(isLoggedIn)")
            }
        } else {
            // Placeholder view during login
            Color.white
                .ignoresSafeArea()
        }
    }

    private func applyFilters(to events: [EventAccepted]) {
        var updatedEvents = events
        if !searchText.isEmpty {
            updatedEvents = updatedEvents.filter { event in
                event.title.lowercased().contains(searchText.lowercased()) ||
                event.artist.name.lowercased().contains(searchText.lowercased()) ||
                event.venue.name.lowercased().contains(searchText.lowercased())
            }
        }
        print("Filtered \(events.count) events")
        filteredEvents = updatedEvents
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Preview Disabled")
            .previewDisplayName("Preview Disabled for Stability")
    }
}
