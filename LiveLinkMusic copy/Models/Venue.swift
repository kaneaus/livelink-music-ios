import Foundation
import CoreLocation

struct Venue: Identifiable, Equatable {
    let id: UUID
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let capacity: Int
    let imageName: String
    
    static func == (lhs: Venue, rhs: Venue) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.address == rhs.address &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude &&
               lhs.capacity == rhs.capacity &&
               lhs.imageName == rhs.imageName
    }
}
