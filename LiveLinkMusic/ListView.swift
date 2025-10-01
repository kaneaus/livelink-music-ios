import SwiftUI

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
