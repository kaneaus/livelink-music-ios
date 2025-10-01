import SwiftUI
import MapKit
import CoreLocation
import UIKit // For UIPasteboard

struct EventDetailsView: View {
    let event: EventAccepted
    let previousScreen: ContentView.Screen
    @Binding var currentScreen: ContentView.Screen
    @State private var isDescriptionExpanded: Bool = false
    @State private var mapRegion: MKCoordinateRegion
    @State private var detailedAddress: String = "Loading address..."
    @State private var addressHeight: CGFloat = 0

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

    private var needsReadMore: Bool {
        guard let description = event.description else { return false }
        let lineCount = description.components(separatedBy: .newlines).count
        return lineCount > 3 || description.count > 200
    }

    private func fetchDetailedAddress() {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: event.venue.coordinate.latitude, longitude: event.venue.coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                detailedAddress = event.venue.address
                return
            }
            if let placemark = placemarks?.first {
                let components = [
                    placemark.subThoroughfare,
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode
                ].compactMap { $0 }.joined(separator: ", ")
                detailedAddress = components.isEmpty ? event.venue.address : components
            } else {
                detailedAddress = event.venue.address
            }
        }
    }

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
