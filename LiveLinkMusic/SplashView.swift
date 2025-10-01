import SwiftUI

struct SplashView: View {
    let completion: () -> Void
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Image("linksIconstart")
                .resizable()
                .scaledToFit()
                .frame(width: 132, height: 132)
        }
        .scaleEffect(size)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                self.size = 0.9
                self.opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                completion()
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(completion: {})
    }
}
