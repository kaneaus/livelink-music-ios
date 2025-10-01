import Foundation
import CoreLocation

class EventService: ObservableObject {
    @Published var events: [EventAccepted] = []
    
    func fetchEvents(userLocation: CLLocationCoordinate2D?) async {
        let apiKey = "QSjS6HyC0qwyatut5cGrAKrTKcBzLPGu"
        
        // Use user's location if available; otherwise, default to Miami, FL
        let latitude: Double
        let longitude: Double
        if let location = userLocation {
            latitude = location.latitude
            longitude = location.longitude
        } else {
            latitude = 25.7617 // Miami, FL
            longitude = -80.1918
        }
        
        // Set date range: today to 7 days from now
        let currentDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
        
        // Format dates for Ticketmaster API (ISO 8601 format)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        let startDateString = dateFormatter.string(from: currentDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        // Construct the API URL with filters
        let urlString = "https://app.ticketmaster.com/discovery/v2/events.json?apikey=\(apiKey)&latlong=\(latitude),\(longitude)&radius=5&unit=miles&classificationName=music&startDateTime=\(startDateString)&endDateTime=\(endDateString)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            guard let embedded = json?["_embedded"] as? [String: Any],
                  let eventsJson = embedded["events"] as? [[String: Any]] else { return }
            
            // Use a temporary array to accumulate events
            var tempEvents: [EventAccepted] = []
            
            // Ensure the loop runs sequentially to avoid concurrent mutation
            for eventJson in eventsJson {
                // Basic event details
                let id = UUID()
                let title = eventJson["name"] as? String ?? "Unknown Event"
                
                // Parse event description (prioritize 'info', fallback to 'pleaseNote')
                let info = eventJson["info"] as? String
                let pleaseNote = eventJson["pleaseNote"] as? String
                let description = info?.isEmpty == false ? info : pleaseNote
                // Log raw values for debugging
                print("Event '\(title)': info='\(info ?? "nil")', pleaseNote='\(pleaseNote ?? "nil")', selected description='\(description ?? "nil")'")
                
                // Parse date and time
                let dateString = (eventJson["dates"] as? [String: Any])?["start"] as? [String: Any]
                let localDate = dateString?["localDate"] as? String ?? ""
                let localTime = dateString?["localTime"] as? String ?? ""
                
                // Format start time (e.g., "19:00:00" to "7:00 PM")
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "h:mm a"
                let startTime: String
                if let time = timeFormatter.date(from: localTime) {
                    startTime = displayFormatter.string(from: time)
                } else {
                    startTime = "Unknown"
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: localDate) ?? Date()
                
                // Parse venue
                let venues = (eventJson["_embedded"] as? [String: Any])?["venues"] as? [[String: Any]]
                let venueJson = venues?.first
                let venueAddress = (venueJson?["address"] as? [String: Any])?["line1"] as? String ?? "Unknown Address"
                let suburb = (venueJson?["city"] as? [String: Any])?["name"] as? String ?? "Unknown City"
                let venueImages = venueJson?["images"] as? [[String: Any]]
                let venueImageUrl = venueImages?.first(where: { $0["ratio"] as? String == "16_9" })?["url"] as? String
                
                let location = venueJson?["location"] as? [String: Any]
                let latitude = Double(location?["latitude"] as? String ?? "0") ?? 0
                let longitude = Double(location?["longitude"] as? String ?? "0") ?? 0
                
                // Skip events with invalid coordinates (latitude or longitude of 0)
                guard latitude != 0, longitude != 0 else {
                    print("Skipping event '\(title)' due to invalid coordinates: (\(latitude), \(longitude))")
                    continue
                }
                
                let venue = Venue(
                    id: UUID(),
                    name: venueJson?["name"] as? String ?? "Unknown Venue",
                    address: venueAddress,
                    coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    capacity: venueJson?["capacity"] as? Int ?? 0,
                    imageName: "venuePlaceholder"
                )
                
                // Parse artist
                let attractions = (eventJson["_embedded"] as? [String: Any])?["attractions"] as? [[String: Any]]
                let artistJson = attractions?.first
                let artistImages = artistJson?["images"] as? [[String: Any]]
                let artistImageUrl = artistImages?.first(where: { $0["ratio"] as? String == "16_9" })?["url"] as? String
                let artist = Artist(
                    id: UUID(),
                    name: artistJson?["name"] as? String ?? "Unknown Artist",
                    bio: "",
                    profileImage: "",
                    socialMedia: [:]
                )
                
                // Parse event image URL
                let images = eventJson["images"] as? [[String: Any]]
                let imageUrl = images?.first(where: { $0["ratio"] as? String == "16_9" })?["url"] as? String ?? "https://via.placeholder.com/150"
                
                // Parse price range
                let priceRanges = eventJson["priceRanges"] as? [[String: Any]]
                let priceRange = priceRanges?.first
                let ticketPriceMin = priceRange?["min"] as? Double ?? 0.0
                let ticketPriceMax = priceRange?["max"] as? Double ?? 0.0
                
                // Parse genre and subgenre
                let classifications = eventJson["classifications"] as? [[String: Any]]
                let classification = classifications?.first
                let genre = (classification?["genre"] as? [String: Any])?["name"] as? String ?? "Unknown Genre"
                let subGenre = (classification?["subGenre"] as? [String: Any])?["name"] as? String ?? "Unknown Type"
                
                // Parse duration
                let endTime = (eventJson["dates"] as? [String: Any])?["end"] as? [String: Any]
                let endLocalTime = endTime?["localTime"] as? String
                let duration: String
                if let start = dateString?["localTime"] as? String, let end = endLocalTime {
                    timeFormatter.dateFormat = "HH:mm:ss"
                    if let startDate = timeFormatter.date(from: start), let endDate = timeFormatter.date(from: end) {
                        let interval = endDate.timeIntervalSince(startDate)
                        let hours = Int(interval / 3600)
                        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
                        duration = "\(hours)h \(minutes)m"
                    } else {
                        duration = "Unknown"
                    }
                } else {
                    duration = "Unknown"
                }
                
                // Create EventAccepted object
                let event = EventAccepted(
                    id: id,
                    title: title,
                    artist: artist,
                    venue: venue,
                    date: date,
                    startTime: startTime,
                    ticketPriceMin: ticketPriceMin,
                    ticketPriceMax: ticketPriceMax,
                    coordinate: venue.coordinate,
                    imageUrl: imageUrl,
                    duration: duration,
                    genre: genre,
                    subGenre: subGenre,
                    suburb: suburb,
                    artistImageUrl: artistImageUrl,
                    venueImageUrl: venueImageUrl,
                    description: description
                )
                tempEvents.append(event)
            }
            
            // Assign the temporary array to the published property in a single operation
            let finalEvents = tempEvents
            await MainActor.run {
                self.events = finalEvents
            }
        } catch {
            print("Error fetching events: \(error)")
        }
    }
}
