import SwiftUI

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
