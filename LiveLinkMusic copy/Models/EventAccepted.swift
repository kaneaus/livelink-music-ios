import Foundation
import CoreLocation
struct EventAccepted: Identifiable, Equatable {
    let id: UUID
    let title: String
    let artist: Artist
    let venue: Venue
    let date: Date
    let startTime: String
    let ticketPriceMin: Double
    let ticketPriceMax: Double
    let coordinate: CLLocationCoordinate2D
    let imageUrl: String
    let duration: String
    let genre: String
    let subGenre: String
    let suburb: String
    let artistImageUrl: String?
    let venueImageUrl: String?
    let description: String? // New property for event description
    
    static func == (lhs: EventAccepted, rhs: EventAccepted) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.artist == rhs.artist &&
               lhs.venue == rhs.venue &&
               lhs.date == rhs.date &&
               lhs.startTime == rhs.startTime &&
               lhs.ticketPriceMin == rhs.ticketPriceMin &&
               lhs.ticketPriceMax == rhs.ticketPriceMax &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude &&
               lhs.imageUrl == rhs.imageUrl &&
               lhs.duration == rhs.duration &&
               lhs.genre == rhs.genre &&
               lhs.subGenre == rhs.subGenre &&
               lhs.suburb == rhs.suburb &&
               lhs.artistImageUrl == rhs.artistImageUrl &&
               lhs.venueImageUrl == rhs.venueImageUrl &&
               lhs.description == rhs.description // Include description in equality check
    }
}
