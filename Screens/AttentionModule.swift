import SwiftUI

struct AttentionModule: View {
    @State private var currentScreen = 1
    @State private var selectedHead: AttentionHead?
    @ObservedObject var gameState: GameState
    
    var body: some View {
        ZStack {
            if currentScreen == 1 {
                AttentionExplanationView(selectedHead: $selectedHead) {
                    withAnimation {
                        currentScreen = 2
                    }
                }
            } else {
                AttentionGameView(
                    onComplete: {
                        withAnimation {
                            gameState.currentModule = 4
                        }
                    },
                    gameState: gameState
                )
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing),
                              removal: .move(edge: .leading)))
        .overlay(alignment: .topTrailing) {
            SkipModuleButton(gameState: gameState, currentModule: 3)
                .padding()
        }
    }
}

enum AttentionHead: String, CaseIterable, Sendable {
    case nouns = "Nouns"
    case verbs = "Verbs"
    case emotions = "Emotions"
    case relationships = "Relationships"
    
    var color: Color {
        switch self {
        case .nouns: return .blue
        case .verbs: return .green
        case .emotions: return .red
        case .relationships: return .purple
        }
    }
}

#Preview {
    AttentionModule(gameState: GameState())
} 