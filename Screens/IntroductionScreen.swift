import SwiftUI

struct IntroductionView: View {
    let userName: String
    @ObservedObject var gameState: GameState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var cardsOpacity = 0.0
    @State private var buttonOpacity = 0.0
    
    
    private let infoCards: [(title: String, description: String, systemImage: String)] = [
        (
            title: "What are LLMs?",
            description: "Large Language Models are AI systems that can understand and generate human-like text. They're the technology behind AI chatbots and many modern AI applications.",
            systemImage: "brain.head.profile"
        ),
        (
            title: "Our Journey",
            description: "Over the next 3 minutes, we'll explore how LLMs work through fun interactive games and challenges.",
            systemImage: "map"
        ),
        (
            title: "Ready to Begin?",
            description: "Let's start by understanding how LLMs process text!",
            systemImage: "play.circle.fill"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: horizontalSizeClass == .regular ? 40 : 30) {
                AnimatedTitle(
                    title: "Hi \(userName)! 👋",
                    subtitle: "I'm excited to be your guide into the fascinating world of Large Language Models!",
                    isPad: horizontalSizeClass == .regular
                )
                
                VStack(spacing: 20) {
                    ForEach(Array(infoCards.enumerated()), id: \.offset) { _, card in
                        InfoCard(
                            title: card.title,
                            description: card.description,
                            systemImage: card.systemImage
                        )
                        .frame(maxWidth: horizontalSizeClass == .regular ? 600 : nil)
                    }
                }
                .padding(.horizontal)
                .opacity(cardsOpacity)
                
                Button {
                    withAnimation {
                        gameState.currentModule = 2
                    }
                } label: {
                    Label("Let's Begin!", systemImage: "arrow.right.circle.fill")
                        .font(horizontalSizeClass == .regular ? .title2 : .headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(horizontalSizeClass == .regular ? .large : .regular)
                .opacity(buttonOpacity)
            }
            .padding(.vertical, horizontalSizeClass == .regular ? 60 : 40)
            .padding(.horizontal)
            .frame(maxWidth: 1000)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6).delay(0.6)) {
                cardsOpacity = 1
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.9)) {
                buttonOpacity = 1
            }
        }
    }
} 
