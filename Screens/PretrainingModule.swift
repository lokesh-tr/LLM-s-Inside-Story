import SwiftUI

struct PretrainingModule: View {
    @State private var currentScreen = 1
    @StateObject private var state = PretrainingState()
    @ObservedObject var gameState: GameState
    
    var body: some View {
        ZStack {
            if currentScreen == 1 {
                PretrainingExplanationView(
                    state: state,
                    onContinue: {
                        withAnimation {
                            currentScreen = 2
                        }
                    }
                )
            } else {
                PretrainingTestView(
                    state: state,
                    gameState: gameState,
                    onComplete: {
                        withAnimation {
                            gameState.currentModule = 5
                        }
                    },
                    onRetry: {
                        withAnimation {
                            currentScreen = 1
                        }
                    }
                )
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing),
                              removal: .move(edge: .leading)))
        .overlay(alignment: .topTrailing) {
            SkipModuleButton(gameState: gameState, currentModule: 4)
                .padding()
        }
    }
}

#Preview {
    PretrainingModule(gameState: GameState())
} 