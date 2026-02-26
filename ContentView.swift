
import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var userName: String = ""
    @State private var showNameInput: Bool = false
    @State private var animationCompleted: Bool = false
    @StateObject private var tokenizationState = TokenizationState()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                switch gameState.currentModule {
                case 1:
                    if !animationCompleted {
                        WelcomeAnimation(animationCompleted: $animationCompleted)
                    } else if !showNameInput {
                        WelcomeView(showNameInput: $showNameInput)
                            .transition(.opacity)
                    } else {
                        NameInputView(userName: $userName, gameState: gameState)
                            .transition(.opacity)
                    }
                case 2:
                    TokenizationExplanationView(state: tokenizationState, gameState: gameState)
                        .transition(.opacity)
                case 3:
                    AttentionModule(gameState: gameState)
                        .transition(.opacity)
                case 4:
                    PretrainingModule(gameState: gameState)
                        .transition(.opacity)
                case 5:
                    FineTuningModule(gameState: gameState)
                        .transition(.opacity)
                case 6:
                    NextWordPredictionModule(gameState: gameState)
                        .transition(.opacity)
                case 7:
                    ReflectionModule(gameState: gameState)
                        .transition(.opacity)
                case 8:
                    TrendingIssuesModule(gameState: gameState)
                        .transition(.opacity)
                case 9:
                    ClosingModule(gameState: gameState)
                        .transition(.opacity)
                default:
                    Text("Module not found")
                        .foregroundColor(.primary)
                }
            }
            .animation(.easeInOut, value: gameState.currentModule)
            .animation(.easeInOut, value: showNameInput)
            .animation(.easeInOut, value: animationCompleted)
            
            
            .overlay(alignment: .top) {
                if gameState.currentModule > 1 {
                    ScoreView(score: gameState.totalScore)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
