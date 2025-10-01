import SwiftUI
import CoreLocation
struct EventAnnotationView: View {
    let event: EventAccepted
    let isSelected: Bool
    var body: some View {
        Image(isSelected ? "eventPinSelected" : "eventPin") // Use eventPinSelected when selected
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
            .scaleEffect(isSelected ? 1.2 : 1.0) // Increase size by 20% when selected
    }
}
struct EventAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        EventAnnotationView(
            event: EventAccepted(
                id: UUID(),
                title: "Sample Event",
                artist: Artist(id: UUID(), name: "Sample Artist", bio: "", profileImage: "", socialMedia: [:]),
                venue: Venue(id: UUID(), name: "Sample Venue", address: "", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), capacity: 0, imageName: ""),
                date: Date(),
                startTime: "7:00 PM",
                ticketPriceMin: 0.0,
                ticketPriceMax: 0.0,
                coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                imageUrl: "",
                duration: "",
                genre: "",
                subGenre: "",
                suburb: "",
                artistImageUrl: nil,
                venueImageUrl: nil,
                description: "This is a sample event description for preview purposes."
            ),
            isSelected: true
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
