import SwiftUI
import MapKit

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
