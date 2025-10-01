import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var otpCode: String = ""
    @State private var name: String = ""
    @State private var dateOfBirth: String = ""
    @State private var selectedRole: Role? = nil
    @State private var currentScreen: Screen = .login
    @EnvironmentObject var locationManager: LocationManager
    
    enum Screen {
        case login
        case otpScreen
        case signUp
        case signUpRole
        case welcome
    }
    
    enum Role: String {
        case artist = "Artist"
        case venue = "Venue"
        case fan = "Fan"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
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
                        currentScreen = .welcome
                    })
                case .welcome:
                    WelcomeScreen(nextAction: {
                        UserDefaults.standard.set(true, forKey: "hasCompletedLogin")
                    })
                }
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
                .padding(.horizontal, 40)
            
            Text("Enter your email. If you don’t have an account we’ll create one")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text("Email Address")
                .font(.custom("Inter-SemiBold", size: 16))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
            
            TextField("Enter your email", text: $email)
                .font(.custom("Inter-Regular", size: 16))
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 40)
            
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, 40)
                
                Text("Continue with")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    .background(Color.white)
            }
            .padding(.vertical, 10)
            
            Button(action: {
                // Placeholder for Google login
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
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 40)
            }
            
            Button(action: {
                // Placeholder for Apple login
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
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
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
            .padding(.bottom, 40)
        }
        .padding(.top, 64)
        .ignoresSafeArea(.all, edges: .top)
    }
}

struct OTPScreenView: View {
    @Binding var otpCode: String
    let backAction: () -> Void
    let nextAction: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image("linksIconstart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                
                Text("Enter your one time password")
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Text("A one time password was sent to your email")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Text("Enter OTP")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                TextField("Enter OTP", text: $otpCode)
                    .font(.custom("Inter-Regular", size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                
                Spacer()
                
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
                .padding(.bottom, 40)
            }
            .padding(.top, 64)
            .ignoresSafeArea(.all, edges: .top)
            
            HStack {
                Button(action: {
                    backAction()
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
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 16)
            .padding(.leading, 16)
        }
    }
}

struct SignUpScreenView: View {
    @Binding var name: String
    @Binding var dateOfBirth: String
    let backAction: () -> Void
    let nextAction: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image("linksIconstart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                
                Text("Create your profile to get started")
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Text("Add some quick personal details for your profile")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        Text("Add photo")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        // Placeholder for photo selection
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
                
                Text("Full Name")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                TextField("Enter your full name", text: $name)
                    .font(.custom("Inter-Regular", size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                
                Text("Date of Birth")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                TextField("MM/DD/YYYY", text: $dateOfBirth)
                    .font(.custom("Inter-Regular", size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                
                Spacer()
                
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
                .padding(.bottom, 40)
            }
            .padding(.top, 64)
            .ignoresSafeArea(.all, edges: .top)
            
            HStack {
                Button(action: {
                    backAction()
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
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 16)
            .padding(.leading, 16)
        }
    }
}

struct SignUpRoleScreenView: View {
    @Binding var selectedRole: LoginView.Role?
    let backAction: () -> Void
    let nextAction: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image("linksIconstart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                
                Text("What kind of profile do you want to sign up as")
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Text("All profile types will be able to access LiveLink's find a gig feature")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
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
                                    .stroke(selectedRole == .artist ? Color(hex: "FF9B00") : Color.gray.opacity(0.3), lineWidth: 2)
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
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
                                    .stroke(selectedRole == .venue ? Color(hex: "FF9B00") : Color.gray.opacity(0.3), lineWidth: 2)
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
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
                                    .stroke(selectedRole == .fan ? Color(hex: "FF9B00") : Color.gray.opacity(0.3), lineWidth: 2)
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
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
                
                Spacer()
                
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
                .disabled(selectedRole == nil)
                .padding(.bottom, 40)
            }
            .padding(.top, 64)
            .ignoresSafeArea(.all, edges: .top)
            
            HStack {
                Button(action: {
                    backAction()
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
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 16)
            .padding(.leading, 16)
        }
    }
}

struct WelcomeScreen: View {
    let nextAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image("linksIconstart")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            
            Text("Let’s Find Live Music!")
                .font(.custom("Inter-Bold", size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            Text("Start exploring events and venues in your area.")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
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
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.top, 24)
        .ignoresSafeArea(.all, edges: .top)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(LocationManager())
    }
}
