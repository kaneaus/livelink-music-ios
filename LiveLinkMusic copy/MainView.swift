import SwiftUI
import MapKit
import CoreLocation
import UIKit // For UIPasteboard
// Parent view to manage screen state
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
// Map View (Home Screen)
struct MapView: View {
    @ObservedObject var eventService: EventService
    @ObservedObject var mapService: MapService
    @ObservedObject var locationManager: LocationManager
    @Binding var filteredEvents: [EventAccepted]
    @Binding var region: MKCoordinateRegion
    @Binding var selectedEvent: EventAccepted?
    @Binding var searchText: String
    @Binding var showFilterSheet: Bool
    @Binding var selectedCategory: String
    @Binding var currentScreen: ContentView.Screen
    let applyFilters: ([EventAccepted]) -> Void
    @State private var showMultiEventSheet: Bool = false
    @State private var eventsAtLocation: [EventAccepted] = []
    private func annotationView(for events: [EventAccepted], isSelected: Bool) -> some View {
        let eventCount = events.count
        let firstEvent = events.first!
        return ZStack {
            EventAnnotationView(event: firstEvent, isSelected: isSelected)
                .onTapGesture {
                    if eventCount > 1 {
                        eventsAtLocation = events
                        showMultiEventSheet = true
                    } else {
                        currentScreen = .eventDetails(firstEvent, .map)
                        selectedEvent = firstEvent
                        withAnimation {
                            region.center = firstEvent.coordinate
                            region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        }
                    }
                }
                .onAppear {
                    print("Rendering pin for events at coordinate (\(firstEvent.coordinate.latitude), \(firstEvent.coordinate.longitude)), Count: \(eventCount)")
                }
            
            if eventCount > 1 {
                Text("\(eventCount)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color(hex: "FF9B00"))
                    .clipShape(Circle())
                    .offset(x: 15, y: -15)
            }
        }
    }
    private var eventsByCoordinate: [(coordinate: CLLocationCoordinate2D, events: [EventAccepted])] {
        var dict: [String: [EventAccepted]] = [:]
        for event in filteredEvents {
            let key = "\(event.coordinate.latitude),\(event.coordinate.longitude)"
            if dict[key] == nil {
                dict[key] = [event]
            } else {
                dict[key]?.append(event)
            }
        }
        
        return dict.map { (key, value) in
            let coords = coordinateStringToCoordinate(coordinateString: key)
            return (coords, value)
        }.sorted { $0.events.count > $1.events.count }
    }
    private func coordinateStringToCoordinate(coordinateString: String) -> CLLocationCoordinate2D {
        let components = coordinateString.split(separator: ",").map { Double($0) ?? 0 }
        return CLLocationCoordinate2D(latitude: components[0], longitude: components[1])
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map {
                    ForEach(eventsByCoordinate, id: \.coordinate.latitude) { group in
                        Annotation("", coordinate: group.coordinate) {
                            annotationView(for: group.events, isSelected: selectedEvent?.id == group.events.first?.id)
                        }
                    }
                    if let userLocation = locationManager.userLocation {
                        Annotation("", coordinate: userLocation) {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(radius: 2)
                        }
                    }
                }
                .mapStyle(.standard)
                .ignoresSafeArea()
                VStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color.black.opacity(0.01)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 280)
                    .ignoresSafeArea(edges: .top)
                    
                    Spacer()
                }
                VStack(spacing: 0) {
                    HeaderView(
                        isMapView: true,
                        switchToMap: { currentScreen = .map },
                        switchToList: { currentScreen = .list }
                    )
                    .onAppear { print("HeaderView rendered") }
                    LocationIndicatorView(isMapView: true)
                        .onAppear { print("LocationIndicatorView rendered") }
                    SearchAndFilterView(
                        searchText: $searchText,
                        showFilterSheet: $showFilterSheet,
                        selectedCategory: $selectedCategory,
                        applyFilters: applyFilters,
                        events: eventService.events,
                        showFilterButton: false
                    )
                    .onAppear { print("SearchAndFilterView rendered") }
                    Spacer()
                    CardSliderView(
                        filteredEvents: filteredEvents,
                        selectedEvent: $selectedEvent,
                        onEventSelected: { event in
                            currentScreen = .eventDetails(event, .map)
                            selectedEvent = event
                            withAnimation {
                                region.center = event.coordinate
                                region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            }
                        }
                    )
                    .padding(.top, 10)
                    .padding(.bottom, 4)
                    BottomMenuBar(currentScreen: $currentScreen)
                }
            }
        }
        .background(Color.white)
        .onChange(of: eventService.events) { _, newEvents in
            applyFilters(newEvents)
        }
        .onAppear {
            if let userLocation = locationManager.userLocation, selectedEvent == nil {
                withAnimation {
                    region = MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
        .sheet(isPresented: $showMultiEventSheet) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Events at this Location")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.horizontal)
                ScrollView {
                    ForEach(eventsAtLocation) { event in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(event.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text(event.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(event.startTime)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                        .onTapGesture {
                            currentScreen = .eventDetails(event, .map)
                            selectedEvent = event
                            showMultiEventSheet = false
                            withAnimation {
                                region.center = event.coordinate
                                region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            }
                        }
                    }
                }
                Spacer()
                Button(action: {
                    showMultiEventSheet = false
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
// List View (Separate Screen)
struct ListView: View {
    @ObservedObject var eventService: EventService
    @Binding var filteredEvents: [EventAccepted]
    @Binding var selectedEvent: EventAccepted?
    @Binding var searchText: String
    @Binding var showFilterSheet: Bool
    @Binding var selectedCategory: String
    @Binding var currentScreen: ContentView.Screen
    let applyFilters: ([EventAccepted]) -> Void
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    HeaderView(
                        isMapView: false,
                        switchToMap: { currentScreen = .map },
                        switchToList: { currentScreen = .list }
                    )
                    .onAppear { print("HeaderView rendered in ListView") }
                    LocationIndicatorView(isMapView: false)
                        .onAppear { print("LocationIndicatorView rendered in ListView") }
                    SearchAndFilterView(
                        searchText: $searchText,
                        showFilterSheet: $showFilterSheet,
                        selectedCategory: $selectedCategory,
                        applyFilters: applyFilters,
                        events: eventService.events,
                        showFilterButton: true
                    )
                    .onAppear { print("SearchAndFilterView rendered in ListView") }
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredEvents) { event in
                                EventCardView(event: event)
                                    .frame(width: geometry.size.width - 40)
                                    .onTapGesture {
                                        currentScreen = .eventDetails(event, .list)
                                        selectedEvent = event
                                    }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    BottomMenuBar(currentScreen: $currentScreen)
                }
            }
        }
        .background(Color.white)
        .onChange(of: eventService.events) { _, newEvents in
            applyFilters(newEvents)
        }
    }
}
// Event Details View
struct EventDetailsView: View {
    let event: EventAccepted
    let previousScreen: ContentView.Screen
    @Binding var currentScreen: ContentView.Screen
    @State private var isDescriptionExpanded: Bool = false // Track description state
    @State private var mapRegion: MKCoordinateRegion // State for map region
    @State private var detailedAddress: String = "Loading address..." // State for detailed address
    @State private var addressHeight: CGFloat = 0 // State for address text height
    
    init(event: EventAccepted, previousScreen: ContentView.Screen, currentScreen: Binding<ContentView.Screen>) {
        self.event = event
        self.previousScreen = previousScreen
        self._currentScreen = currentScreen
        self._mapRegion = State(initialValue: MKCoordinateRegion(
            center: event.venue.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    private var countdown: String {
        let currentDate = Date()
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        let eventDateString = "\(calendar.component(.year, from: event.date))-\(String(format: "%02d", calendar.component(.month, from: event.date)))-\(String(format: "%02d", calendar.component(.day, from: event.date))) \(event.startTime)"
        guard let eventStartDate = dateFormatter.date(from: eventDateString) else {
            return "Unknown"
        }
        
        let interval = eventStartDate.timeIntervalSince(currentDate)
        if interval <= 0 {
            return "Event Started"
        }
        
        let days = Int(interval / (24 * 3600))
        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s")"
        }
        let hours = Int(interval / 3600)
        if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }
        let minutes = Int(interval / 60)
        return "\(minutes) minute\(minutes == 1 ? "" : "s")"
    }
    private func formatTimeTo12Hour(_ time: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date = dateFormatter.date(from: time) {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: date)
        }
        return time
    }
    
    // Determine if description needs truncation
    private var needsReadMore: Bool {
        guard let description = event.description else { return false }
        let lineCount = description.components(separatedBy: .newlines).count
        return lineCount > 3 || description.count > 200 // Approximate check for long text
    }
    
    // Reverse geocode to get detailed address
    private func fetchDetailedAddress() {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: event.venue.coordinate.latitude, longitude: event.venue.coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                detailedAddress = event.venue.address // Fallback to basic address
                return
            }
            if let placemark = placemarks?.first {
                let components = [
                    placemark.subThoroughfare, // Street number
                    placemark.thoroughfare, // Street name
                    placemark.locality, // City
                    placemark.administrativeArea, // State
                    placemark.postalCode // ZIP
                ].compactMap { $0 }.joined(separator: ", ")
                detailedAddress = components.isEmpty ? event.venue.address : components
            } else {
                detailedAddress = event.venue.address // Fallback to basic address
            }
        }
    }
    
    // Copy address to clipboard
    private func copyAddress() {
        UIPasteboard.general.string = detailedAddress
        print("Copied address to clipboard: \(detailedAddress)")
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ZStack {
                    AsyncImage(url: URL(string: event.imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                            .clipped()
                    } placeholder: {
                        Color.gray
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                    }
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: "FF7043").opacity(0.9))
                            .frame(width: 268, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Text(countdown)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    .position(x: geometry.size.width / 2, y: (geometry.size.height * 0.4) * 0.5)
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                .ignoresSafeArea(edges: .top)
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: geometry.size.height * 0.4 - 20)
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(event.title.uppercased())
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .lineLimit(3)
                                Spacer()
                                Image("sharealternate")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color(hex: "FF9B00"))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geometry.size.width - 40, height: 1)
                                .padding(.horizontal, 20)
                            Text("Artist Information")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            HStack(alignment: .center) {
                                AsyncImage(url: URL(string: event.artistImageUrl ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                        .foregroundColor(.gray)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.artist.name)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    Text("Singer, Songwriter")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, (geometry.size.width * 0.15 - 44) / 2)
                                Spacer()
                                HStack(spacing: 4) {
                                    Image("linksIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                    Text("5 Links")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "FF9B00"))
                                }
                                .frame(width: 110, height: 32)
                                .background(Color(hex: "F2F2F2"))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .padding(.horizontal, 20)
                            Button(action: {}) {
                                Text("View Details")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "FF9B00"), lineWidth: 2)
                                    )
                            }
                            .padding(.horizontal, 20)
                            Text("Gig Description")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.description ?? "No event description provided by the organizer.")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .lineLimit(isDescriptionExpanded ? nil : 3)
                                    .padding(.horizontal, 20)
                                if needsReadMore {
                                    Button(action: {
                                        withAnimation {
                                            isDescriptionExpanded.toggle()
                                        }
                                    }) {
                                        Text(isDescriptionExpanded ? "Read Less" : "Read More...")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(hex: "FF9B00"))
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                            Text("Event Information")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image("EventCal")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(.red)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Event Date")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        HStack(spacing: 8) {
                                            Text(event.date, style: .date)
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                            Text(formatTimeTo12Hour(event.startTime))
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                // Venue Info with Vector Asset
                                ZStack {
                                    HStack(spacing: 8) {
                                        Image("EventLoc")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 36, height: 36)
                                            .foregroundColor(.red)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Venue Name")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.gray)
                                            Text(event.venue.name)
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                        }
                                        Spacer()
                                    }
                                    .frame(height: 36)
                                    .padding(.horizontal, 20)
                                    Image("Vector")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .position(x: geometry.size.width - 32, y: 18)
                                        .onTapGesture {
                                            print("Tapped Vector - Navigate to venue profile screen")
                                        }
                                        .onAppear {
                                            print("Vector position: x = \(geometry.size.width - 32), y = 18, screen width = \(geometry.size.width)")
                                        }
                                }
                                Map {
                                    Annotation("", coordinate: event.venue.coordinate) {
                                        Image("eventPin")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .mapStyle(.standard)
                                .frame(width: geometry.size.width - 40, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top, 24)
                                .padding(.horizontal, 20)
                                ZStack(alignment: .leading) {
                                    GeometryReader { textGeometry in
                                        Text(detailedAddress)
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                            .padding(.top, 24)
                                            .padding(.horizontal, 20)
                                            .lineLimit(nil)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .onAppear {
                                                addressHeight = textGeometry.size.height
                                            }
                                    }
                                    Button(action: {
                                        copyAddress()
                                    }) {
                                        Image("Copy")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(Color(hex: "FF9B00"))
                                    }
                                    .position(x: geometry.size.width - 36, y: addressHeight / 2 + 24)
                                    .onAppear {
                                        print("Copy button position: x = \(geometry.size.width - 36), y = \(addressHeight / 2 + 24), address height = \(addressHeight), screen width = \(geometry.size.width)")
                                    }
                                }
                            }
                            .padding(.bottom, 80)
                        }
                        .background(
                            Color.white
                                .clipShape(
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: 20,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 20
                                    )
                                )
                        )
                    }
                }
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    fetchDetailedAddress()
                }
                Button(action: {
                    currentScreen = previousScreen
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color(hex: "FF9B00"))
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .offset(x: 16, y: 10)
                VStack {
                    Spacer()
                    BottomMenuBar(currentScreen: $currentScreen)
                }
            }
        }
    }
}
// Links View (Placeholder)
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
// Gigs View (Placeholder)
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
// Profile View (Placeholder)
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
// Bottom Menu Bar
struct BottomMenuBar: View {
    @Binding var currentScreen: ContentView.Screen
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { currentScreen = .map }) {
                    Image("homeIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundColor(currentScreen == .map ? Color(hex: "FF9B00") : .gray)
                }
                .frame(maxWidth: .infinity)
                Button(action: { currentScreen = .links }) {
                    Image("linksIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(currentScreen == .links ? Color(hex: "FF9B00") : .gray)
                }
                .frame(maxWidth: .infinity)
                Button(action: { currentScreen = .gigs }) {
                    Image("gigsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundColor(currentScreen == .gigs ? Color(hex: "FF9B00") : .gray)
                }
                .frame(maxWidth: .infinity)
                Button(action: { currentScreen = .profile }) {
                    Image("profileIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundColor(currentScreen == .profile ? Color(hex: "FF9B00") : .gray)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .frame(height: 68)
            .background(Color.white.opacity(0.95))
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
// Reusable Header View
struct HeaderView: View {
    let isMapView: Bool
    let switchToMap: () -> Void
    let switchToList: () -> Void
    var body: some View {
        HStack(spacing: 8) {
            Image("linksIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(isMapView ? .white : .black)
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(isMapView ? .white : .black)
            Spacer()
            Button(action: switchToMap) {
                Image(isMapView ? "mapbutton" : "mapbuttoninv")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(isMapView ? .white : .gray)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 4)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            Button(action: switchToList) {
                Image(isMapView ? "listbutton" : "listbuttoninv")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(isMapView ? .gray : .black)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 4)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 2)
    }
}
// Reusable Location Indicator View
struct LocationIndicatorView: View {
    let isMapView: Bool
    var body: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(isMapView ? .white : .black)
            Text("Miami, FL")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isMapView ? .white : .black)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 2)
    }
}
// Reusable Search and Filter View
struct SearchAndFilterView: View {
    @Binding var searchText: String
    @Binding var showFilterSheet: Bool
    @Binding var selectedCategory: String
    let applyFilters: ([EventAccepted]) -> Void
    let events: [EventAccepted]
    let showFilterButton: Bool
    var body: some View {
        HStack {
            TextField("Search events...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .font(.body)
            if showFilterButton {
                Button(action: { showFilterSheet.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet(selectedCategory: $selectedCategory, onApply: { applyFilters(events) })
        }
    }
}
// Reusable Card Slider View
struct CardSliderView: View {
    let filteredEvents: [EventAccepted]
    @Binding var selectedEvent: EventAccepted?
    let onEventSelected: (EventAccepted) -> Void
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredEvents) { event in
                        EventCardView(event: event)
                            .frame(width: 392, height: 200)
                            .id(event.id)
                            .onTapGesture {
                                onEventSelected(event)
                            }
                    }
                }
                .padding()
            }
            .onChange(of: selectedEvent) { _, newValue in
                if let selectedEvent = newValue {
                    withAnimation {
                        proxy.scrollTo(selectedEvent.id, anchor: .center)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
}
// Event Card View (used in both CardSliderView and ListView)
struct EventCardView: View {
    let event: EventAccepted
    
    private var countdown: String {
        let currentDate = Date()
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        let eventDateString = "\(calendar.component(.year, from: event.date))-\(String(format: "%02d", calendar.component(.month, from: event.date)))-\(String(format: "%02d", calendar.component(.day, from: event.date))) \(event.startTime)"
        guard let eventStartDate = dateFormatter.date(from: eventDateString) else {
            return "Unknown"
        }
        
        let interval = eventStartDate.timeIntervalSince(currentDate)
        if interval <= 0 {
            return "Event Started"
        }
        
        let days = Int(interval / (24 * 3600))
        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s")"
        }
        let hours = Int(interval / 3600)
        if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }
        let minutes = Int(interval / 60)
        return "\(minutes) minute\(minutes == 1 ? "" : "s")"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineLimit(2)
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text(event.suburb)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .lineLimit(1)
                }
                
                Text("•")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text(countdown)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            HStack(spacing: 8) {
                Text(event.genre)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black)
                    .clipShape(Capsule())
                
                Text(event.subGenre)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 80)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Artist")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(event.artist.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .lineLimit(1)
                        }
                        Spacer()
                        AsyncImage(url: URL(string: event.artistImageUrl ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(8)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 80)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Venue")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(event.venue.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .lineLimit(1)
                        }
                        Spacer()
                        AsyncImage(url: URL(string: event.venueImageUrl ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "building.2.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color(hex: "FF9B00"))
                        }
                    }
                    .padding(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
    }
}
// Filter Sheet for Category Filtering
struct FilterSheet: View {
    @Binding var selectedCategory: String
    let onApply: () -> Void
    var body: some View {
        NavigationView {
            Form {
                Picker("Category", selection: $selectedCategory) {
                    Text("All").tag("All")
                    Text("Music").tag("Music")
                    Text("Sports").tag("Sports")
                    Text("Comedy").tag("Comedy")
                }
            }
            .navigationTitle("Filter Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") { onApply() }
                }
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Preview Disabled")
            .previewDisplayName("Preview Disabled for Stability")
    }
}
