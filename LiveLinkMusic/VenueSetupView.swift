import SwiftUI

struct VenueSetupView: View {
    let backAction: () -> Void
    let nextAction: () -> Void
    @State private var selectedImage: UIImage? = nil
    @State private var venueName: String = ""
    @State private var venueType: String = ""
    @State private var location: String = ""
    @State private var capacity: String = ""
    @State private var website: String = ""
    @State private var selectedGenres: [String] = []
    @State private var instagramLink: String = ""
    @State private var facebookLink: String = ""
    @State private var tiktokLink: String = ""
    @State private var showVenueWelcome: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Group {
                    if showVenueWelcome {
                        VenueWelcomeScreen(backAction: backAction, nextAction: {
                            UserDefaults.standard.set(true, forKey: "hasCompletedLogin")
                            nextAction()
                        })
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Header with centered icon
                                HStack(alignment: .center) {
                                    Image("linksIconstart")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .alignmentGuide(.top) { d in d[.top] - 8 } // Previous adjustment
                                }
                                .frame(maxWidth: .infinity)
                                Text("Create your Venue profile")
                                    .font(.custom("Inter-Bold", size: 24))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                Text("Add details to complete your venue profile")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                    // Venue Name
                                    Text("Venue Name")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, (geometry.size.width - 350) / 2)
                                    TextField("Enter your venue name", text: $venueName)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding()
                                        .frame(width: 350)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.horizontal, (geometry.size.width - 350) / 2)
                                    // Venue Type
                                    Text("What kind of venue is it?")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, (geometry.size.width - 350) / 2)
                                    TextField("Bar, Restaurant", text: $venueType)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding()
                                        .frame(width: 350)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.horizontal, (geometry.size.width - 350) / 2)
                                    // Location
                                    Text("Location")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, (geometry.size.width - 350) / 2)
                                    TextField("Address", text: $location)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding()
                                        .frame(width: 350)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.horizontal, (geometry.size.width - 350) / 2)
                                    // Venue Capacity
                                    Text("Venue capacity")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, (geometry.size.width - 350) / 2)
                                    TextField("Capacity", text: $capacity)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding()
                                        .frame(width: 350)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.horizontal, (geometry.size.width - 350) / 2)
                                    // Add Profile Photo
                                    Text("Add Profile Photo")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, (geometry.size.width - 350) / 2)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                            .frame(width: 350, height: 162)
                                            .background(Color.white)
                                        Image("AddImage")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 46)
                                            .overlay(
                                                Button(action: {
                                                    print("Add photo button tapped")
                                                }) {
                                                    Color.clear
                                                }
                                                .frame(width: 80, height: 46)
                                            )
                                    }
                                    .padding(.horizontal, (geometry.size.width - 350) / 2)
                                    // Add Website
                                    Text("Add website")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, (geometry.size.width - 350) / 2)
                                    TextField("Website", text: $website)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding()
                                        .frame(width: 350)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.horizontal, (geometry.size.width - 350) / 2)
                                    // Social Media Links
                                    Text("Social Media Links")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, (geometry.size.width - 350) / 2)
                                    Button(action: {
                                        print("Connect Instagram tapped")
                                    }) {
                                        HStack {
                                            Image("InstagramLogo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                            Text("Connect your Instagram")
                                                .font(.custom("Inter-Regular", size: 16))
                                                .foregroundColor(.black)
                                        }
                                        .frame(width: 350, height: 44)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .padding(.horizontal, (geometry.size.width - 350) / 2)
                                    Button(action: {
                                        print("Connect Facebook tapped")
                                    }) {
                                        HStack {
                                            Image("FacebookLogo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                            Text("Connect your Facebook")
                                                .font(.custom("Inter-Regular", size: 16))
                                                .foregroundColor(.black)
                                        }
                                        .frame(width: 350, height: 44)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .padding(.horizontal, (geometry.size.width - 350) / 2)
                                    Button(action: {
                                        print("Connect TikTok tapped")
                                    }) {
                                        HStack {
                                            Image("TikTokLogo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                            Text("Connect your TikTok")
                                                .font(.custom("Inter-Regular", size: 16))
                                                .foregroundColor(.black)
                                        }
                                        .frame(width: 350, height: 44)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .padding(.horizontal, (geometry.size.width - 350) / 2)
                                    Spacer(minLength: 60) // Reserve space for the fixed Next button
                                }
                            }
                            .safeAreaInset(edge: .bottom, spacing: 0) { EmptyView() } // Prevent scrolling behind safe area
                        }
                    }
                }
                .frame(maxWidth: .infinity) // Remove maxHeight to respect safe area
                .padding(.horizontal, max(0, (geometry.size.width - 350) / 2))
                .background(Color.clear) // No white background to interfere
            }
            
            // Overlay the back button
            Button(action: backAction) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.black)
            }
            .padding(.leading, 16)
            .padding(.top, 20) // Consistent with login screens, moved up
        }
    }
    
    // Fixed Next button at bottom
    VStack {
        Spacer()
        Button(action: {
            showArtistWelcome = true
        }) {
            Text("Next")
                .font(.custom("Inter-Bold", size: 18))
                .foregroundColor(.white)
                .frame(width: 350, height: 44)
                .background(Color(hex: "FF9B00"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.bottom, 20) // Adjusted to avoid cutoff
    }
}

struct ArtistWelcomeScreen: View {
    let backAction: () -> Void
    let nextAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                VStack(spacing: 20) {
                    // Header with centered icon
                    HStack(alignment: .center) {
                        Image("linksIconstart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .alignmentGuide(.top) { d in d[.top] - 8 }
                    }
                    .frame(maxWidth: .infinity)
                    Image("AllDone")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 215.85, height: 162.42)
                    Text("You're all done!")
                        .font(.custom("Inter-Bold", size: 32))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    Text("How it works:")
                        .font(.custom("Inter-Bold", size: 24))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    VStack(spacing: 20) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FF9B00"))
                                    .frame(width: 24, height: 24)
                                Image(systemName: "mappin")
                                    .foregroundColor(.white)
                                    .imageScale(.small)
                            }
                            Text("See gigs that are available for you")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FF9B00"))
                                    .frame(width: 24, height: 24)
                                Image(systemName: "envelope")
                                    .foregroundColor(.white)
                                    .imageScale(.small)
                            }
                            Text("Communicate with venues to book gigs")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FF9B00"))
                                    .frame(width: 24, height: 24)
                                Image(systemName: "music.note")
                                    .foregroundColor(.white)
                                    .imageScale(.small)
                            }
                            Text("Get out there and play!")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity) // Remove maxHeight to respect safe area
                .padding(.horizontal, max(0, (geometry.size.width - 350) / 2))
                .background(Color.clear) // No white background to interfere
                
                // Overlay the back button
                Button(action: backAction) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.black)
                }
                .padding(.leading, 16)
                .padding(.top, geometry.safeAreaInsets.top) // Position at top of safe area
            }
            
            // Fixed Start Exploring button at bottom
            VStack {
                Spacer()
                Button(action: {
                    nextAction()
                }) {
                    Text("Start Exploring")
                        .font(.custom("Inter-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(width: 350, height: 44)
                        .background(Color(hex: "FF9B00"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.bottom, 20) // Adjusted to avoid cutoff
            }
        }
    }
}
