import SwiftUI

struct WelcomeAnimation: View {
    @Binding var animationCompleted: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var logoScale = 0.5
    @State private var logoOpacity = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .resizable()
                .scaledToFit()
                .frame(width: horizontalSizeClass == .regular ? 200 : 100,
                       height: horizontalSizeClass == .regular ? 200 : 100)
                .foregroundColor(.primary)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
            
            AnimatedTitle(
                title: "LLM's Inside Story",
                subtitle: nil,
                isPad: horizontalSizeClass == .regular
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    animationCompleted = true
                }
            }
        }
    }
}

struct WelcomeView: View {
    @Binding var showNameInput: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer(minLength: geometry.size.width > 1000 ? (geometry.size.width - 1000) / 2 : 0)
                
                VStack(spacing: horizontalSizeClass == .regular ? 40 : 30) {
                    Spacer()
                    
                    AnimatedTitle(
                        title: "Welcome to\nLLM's Inside Story",
                        subtitle: "Embark on a journey to discover\nthe magic of Large Language Models",
                        isPad: horizontalSizeClass == .regular
                    )
                    
                    Button("Begin Adventure") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showNameInput = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(horizontalSizeClass == .regular ? .large : .regular)
                    .font(horizontalSizeClass == .regular ? .title2 : .body)
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: 1000)
                
                Spacer(minLength: geometry.size.width > 1000 ? (geometry.size.width - 1000) / 2 : 0)
            }
        }
    }
}

struct NameInputView: View {
    @Binding var userName: String
    @ObservedObject var gameState: GameState
    @FocusState private var isTextFieldFocused: Bool
    @State private var showIntroduction: Bool = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer(minLength: geometry.size.width > 1000 ? (geometry.size.width - 1000) / 2 : 0)
                
                ZStack {
                    VStack(spacing: horizontalSizeClass == .regular ? 40 : 30) {
                        Spacer()
                        
                        AnimatedTitle(
                            title: "What's your name?",
                            subtitle: nil,
                            isPad: horizontalSizeClass == .regular
                        )
                        
                        TextField("Enter your name", text: $userName)
                            .textFieldStyle(.roundedBorder)
                            .font(horizontalSizeClass == .regular ? .title : .body)
                            .padding(.horizontal, horizontalSizeClass == .regular ? geometry.size.width * 0.2 : 50)
                            .focused($isTextFieldFocused)
                            .onAppear {
                                isTextFieldFocused = true
                            }
                        
                        Button("Continue") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isTextFieldFocused = false
                                showIntroduction = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(horizontalSizeClass == .regular ? .large : .regular)
                        .font(horizontalSizeClass == .regular ? .title2 : .body)
                        .disabled(userName.isEmpty)
                        
                        Spacer()
                    }
                    .opacity(showIntroduction ? 0 : 1)
                    
                    if showIntroduction {
                        IntroductionView(userName: userName, gameState: gameState)
                            .opacity(showIntroduction ? 1 : 0)
                    }
                }
                .frame(maxWidth: 1000)
                
                Spacer(minLength: geometry.size.width > 1000 ? (geometry.size.width - 1000) / 2 : 0)
            }
        }
    }
} 
