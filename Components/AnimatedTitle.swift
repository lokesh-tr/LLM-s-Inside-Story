import SwiftUI

struct AnimatedTitle: View {
    let title: String
    let subtitle: String?
    let isPad: Bool
    @State private var titleOpacity = 0.0
    @State private var subtitleOpacity = 0.0
    
    var body: some View {
        VStack(spacing: isPad ? 16 : 12) {
            Text(title)
                .font(isPad ? .largeTitle : .title)
                .bold()
                .opacity(titleOpacity)
            
            if let subtitle {
                Text(subtitle)
                    .font(isPad ? .title3 : .body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                titleOpacity = 1
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                subtitleOpacity = 1
            }
        }
    }
}

#Preview {
    AnimatedTitle(
        title: "Welcome",
        subtitle: "Let's explore together",
        isPad: true
    )
    .padding()
} 