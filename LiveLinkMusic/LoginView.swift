import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var otpCode: String = ""
    @State private var name: String = ""
    @State private var dateOfBirth: String = ""
    @State private var selectedRole: Role? = nil
    @State private var currentScreen: Screen = .login
    @EnvironmentObject var locationManager: LocationManager
    let completion: () -> Void
    
    enum Screen {
        case login
        case otpScreen
        case signUp
        case signUpRole
        case welcome
        case venueSetup
        case artistSetup
    }
    
    enum Role: String {
        case artist = "Artist"
        case venue = "Venue"
        case fan = "Fan"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear // No background interference
                
                VStack(spacing: 20) {
                    Spacer().frame(height: 40) // Spacer to push content down from the top
                    
                    VStack(spacing: 20) {
                        switch currentScreen {
                        case .login:
                            LoginScreenView(email: $email, nextAction: { currentScreen = .otpScreen })
                        case .otpScreen:
                            OTPScreenView(otpCode: $otpCode, backAction: { currentScreen = .login }, nextAction: { currentScreen = .signUp })
                        case .signUp:
                            SignUpScreenView(name: $name, dateOfBirth: $dateOfBirth, backAction: { currentScreen = .otpScreen }, nextAction: { currentScreen = .signUpRole })
                        case .signUpRole:
                            SignUpRoleScreenView(selectedRole: $selectedRole, backAction: { currentScreen = .signUp }, nextAction: {
                                locationManager.requestWhenInUseAuthorization()
                                if let role = selectedRole {
                                    switch role {
                                    case .fan:
                                        currentScreen = .welcome
                                    case .venue:
                                        currentScreen = .venueSetup
                                    case .artist:
                                        currentScreen = .artistSetup
                                    }
                                }
                            })
                        case .welcome:
                            WelcomeScreen(backAction: { currentScreen = .signUpRole }, nextAction: {
                                UserDefaults.standard.set(true, forKey: "hasCompletedLogin")
                                completion()
                            })
                        case .venueSetup:
                            VenueSetupView(backAction: { currentScreen = .signUpRole }, nextAction: {
                                UserDefaults.standard.set(true, forKey: "hasCompletedLogin")
                                completion()
                            })
                        case .artistSetup:
                            ArtistSetupView(backAction: { currentScreen = .signUpRole }, nextAction: {
                                UserDefaults.standard.set(true, forKey: "hasCompletedLogin")
                                completion()
                            })
                        }
                    }
                    
                    Spacer() // Center content vertically
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height) // Constrain height
                .padding(.horizontal, max(0, (geometry.size.width - 350) / 2)) // Center 350-width content
                .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 0) } // Manage bottom safe area
            }
        }
    }
}

struct LoginScreenView: View {
    @Binding var email: String
    let nextAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image("linksIconstart")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            
            Text("Welcome to LiveLink, find live music here")
                .font(.custom("Inter-Bold", size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("Enter your email. If you don’t have an account we’ll create one")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text("Email Address")
                .font(.custom("Inter-SemiBold", size: 16))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter your email", text: $email)
                .font(.custom("Inter-Regular", size: 16))
                .padding()
                .frame(width: 350)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Text("Continue with")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    .background(Color.white)
            }
            .padding(.vertical, 10)
            
            Button(action: {
                print("Google login tapped")
                nextAction()
            }) {
                HStack {
                    Image("GoogleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("Continue with Google")
                        .font(.custom("Inter-SemiBold", size: 16))
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
            
            Button(action: {
                print("Apple login tapped")
                nextAction()
            }) {
                HStack {
                    Image("AppleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("Continue with Apple")
                        .font(.custom("Inter-SemiBold", size: 16))
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
            
            Spacer() // Push button to the bottom
            
            Button(action: {
                nextAction()
                print("Email login attempted with: \(email)")
            }) {
                Text("Next")
                    .font(.custom("Inter-Bold", size: 18))
                    .foregroundColor(.white)
                    .frame(width: 350, height: 44)
                    .background(Color(hex: "FF9B00"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.bottom, 20) // Reduced padding for natural placement
        }
    }
}

struct OTPScreenView: View {
    @Binding var otpCode: String
    let backAction: () -> Void
    let nextAction: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                Image("linksIconstart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                
                Text("Enter your one time password")
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text("A one time password was sent to your email")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text("Enter OTP")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Enter OTP", text: $otpCode)
                    .font(.custom("Inter-Regular", size: 16))
                    .padding()
                    .frame(width: 350)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer() // Push button to the bottom
                
                Button(action: {
                    nextAction()
                    print("OTP verification attempted with code: \(otpCode)")
                }) {
                    Text("Verify")
                        .font(.custom("Inter-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(width: 350, height: 44)
                        .background(Color(hex: "FF9B00"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.bottom, 20) // Reduced padding for natural placement
            }
            
            Button(action: backAction) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.black)
            }
            .padding(.leading, 16)
            .padding(.top, 20) // Moved up by reducing padding from 40 to 20
        }
    }
}

struct SignUpScreenView: View {
    @Binding var name: String
    @Binding var dateOfBirth: String
    let backAction: () -> Void
    let nextAction: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                Image("linksIconstart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                
                Text("Create your profile to get started")
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text("Add some quick personal details for your profile")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    VStack(spacing: 4) {
                        Image("AddProfileImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        Text("Add photo")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        print("Edit photo tapped")
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(hex: "FF9B00"))
                    }
                    .offset(x: 48, y: 48)
                }
                
                Spacer()
                
                Text("Full Name")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Enter your full name", text: $name)
                    .font(.custom("Inter-Regular", size: 16))
                    .padding()
                    .frame(width: 350)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text("Date of Birth")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("MM/DD/YYYY", text: $dateOfBirth)
                    .font(.custom("Inter-Regular", size: 16))
                    .padding()
                    .frame(width: 350)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer() // Push button to the bottom
                
                Button(action: {
                    nextAction()
                    print("Sign up attempted with name: \(name), DOB: \(dateOfBirth)")
                }) {
                    Text("Next")
                        .font(.custom("Inter-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(width: 350, height: 44)
                        .background(Color(hex: "FF9B00"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.bottom, 20) // Reduced padding for natural placement
            }
            
            Button(action: backAction) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.black)
            }
            .padding(.leading, 16)
            .padding(.top, 20) // Moved up by reducing padding from 40 to 20
        }
    }
}

struct SignUpRoleScreenView: View {
    @Binding var selectedRole: LoginView.Role?
    let backAction: () -> Void
    let nextAction: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                Image("linksIconstart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                
                Text("What kind of profile do you want to sign up as")
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text("All profile types will be able to access LiveLink's find a gig feature")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button(action: {
                    selectedRole = .artist
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 350, height: 108)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedRole == .artist ? Color(hex: "FF9B00") : Color.gray, lineWidth: 1)
                            )
                        
                        HStack(spacing: 12) {
                            Image(selectedRole == .artist ? "ArtLogoSel" : "ArtLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .foregroundColor(selectedRole == .artist ? Color(hex: "FF9B00") : .gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Artist")
                                    .font(.custom("Inter-Bold", size: 24))
                                    .foregroundColor(.black)
                                Text("Sign up as an artist to search and book gigs with LiveLink")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    selectedRole == .artist ?
                                        Circle()
                                            .fill(Color(hex: "FF9B00"))
                                            .frame(width: 10, height: 10)
                                        : nil
                                )
                                .padding(.trailing, 16)
                        }
                        .padding(.leading, 36)
                        .padding(.trailing, 16)
                    }
                }
                
                Button(action: {
                    selectedRole = .venue
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 350, height: 108)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedRole == .venue ? Color(hex: "FF9B00") : Color.gray, lineWidth: 1)
                            )
                        
                        HStack(spacing: 12) {
                            Image(selectedRole == .venue ? "VenLogoSel" : "VenLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .foregroundColor(selectedRole == .venue ? Color(hex: "FF9B00") : .gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Venue")
                                    .font(.custom("Inter-Bold", size: 24))
                                    .foregroundColor(.black)
                                Text("Sign up as a venue to list events and find local artists for your venue")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    selectedRole == .venue ?
                                        Circle()
                                            .fill(Color(hex: "FF9B00"))
                                            .frame(width: 10, height: 10)
                                        : nil
                                )
                                .padding(.trailing, 16)
                        }
                        .padding(.leading, 36)
                        .padding(.trailing, 16)
                    }
                }
                
                Button(action: {
                    selectedRole = .fan
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 350, height: 108)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedRole == .fan ? Color(hex: "FF9B00") : Color.gray, lineWidth: 1)
                            )
                        
                        HStack(spacing: 12) {
                            Image(selectedRole == .fan ? "PatLogoSel" : "PatLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .foregroundColor(selectedRole == .fan ? Color(hex: "FF9B00") : .gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Fan")
                                    .font(.custom("Inter-Bold", size: 24))
                                    .foregroundColor(.black)
                                Text("Sign up to LiveLink to see upcoming gigs in your area")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    selectedRole == .fan ?
                                        Circle()
                                            .fill(Color(hex: "FF9B00"))
                                            .frame(width: 10, height: 10)
                                        : nil
                                )
                                .padding(.trailing, 16)
                        }
                        .padding(.leading, 36)
                        .padding(.trailing, 16)
                    }
                }
                
                Spacer() // Push button to the bottom
                
                Button(action: {
                    nextAction()
                    print("Role selected: \(selectedRole?.rawValue ?? "None")")
                }) {
                    Text("Next")
                        .font(.custom("Inter-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(width: 350, height: 44)
                        .background(selectedRole == nil ? Color.gray.opacity(0.5) : Color(hex: "FF9B00"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.bottom, 20) // Reduced padding for natural placement
            }
            
            Button(action: backAction) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.black)
            }
            .padding(.leading, 16)
            .padding(.top, 20) // Moved up by reducing padding from 40 to 20
        }
    }
}

struct WelcomeScreen: View {
    let backAction: () -> Void
    let nextAction: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 50)
                
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
                        Text("Use the map to see gigs that are happening now or in the next 48 hours")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FF9B00"))
                                .frame(width: 24, height: 24)
                            Image(systemName: "link")
                                .foregroundColor(.white)
                                .imageScale(.small)
                        }
                        Text("“Link” your favourite artists or venues to receive notifications when they have a gig")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FF9B00"))
                                .frame(width: 24, height: 24)
                            Image(systemName: "music.note")
                                .foregroundColor(.white)
                                .imageScale(.small)
                        }
                        Text("Enjoy the music!")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
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
                .padding(.bottom, 40)
            }
            
            Button(action: backAction) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.black)
            }
            .padding(.leading, 16)
            .padding(.top, 20) // Moved up by reducing padding from 40 to 20
        }
    }
}
