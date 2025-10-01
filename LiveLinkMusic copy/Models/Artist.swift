import Foundation

struct Artist: Identifiable, Equatable {
    let id: UUID
    let name: String
    let bio: String
    let profileImage: String
    let socialMedia: [String: String]
    
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.bio == rhs.bio &&
               lhs.profileImage == rhs.profileImage &&
               lhs.socialMedia == rhs.socialMedia
    }
}
