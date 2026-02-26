import SwiftUI

struct TrendingIssuesModule: View {
    @ObservedObject var gameState: GameState
    @State private var selectedGame: MiniGame?
    @State private var showingGameView = false
    @State private var showingReturnToReflection = false
    
    enum MiniGame: String, CaseIterable {
        case audioRefinement = "Audio Data Refinement"
        case energyReduction = "Energy Consumption Reduction"
        case safeGuard = "Safe Guard"
        
        var theme: String {
            switch self {
            case .audioRefinement: return "Accessibility"
            case .energyReduction: return "Environment"
            case .safeGuard: return "Privacy"
            }
        }
        
        var icon: String {
            switch self {
            case .audioRefinement: return "waveform"
            case .energyReduction: return "leaf.fill"
            case .safeGuard: return "shield.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .audioRefinement: return .purple
            case .energyReduction: return .green
            case .safeGuard: return .blue
            }
        }
        
        var description: String {
            switch self {
            case .audioRefinement:
                return "Lumon Industries are working towards making LLMs more accessible to the people by introducing a new voice mode to interact with the models. But there's a catch, unexpected noises and anomalies disturb the audio signals and thus the LLMs can't process the signals. Help Mark S. (Department Chief of ADR) to refine the audio signals."
            case .energyReduction:
                return "The models are using lots of energy to provide best results. From what you learnt in fine tuning module, help save the earth by optimising the model parameters to reduce energy consumption."
            case .safeGuard:
                return "Privacy is a fundamental human right. Help protect user data by erasing personal information from the prompt messages before it actually gets sent to the user."
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 30) {
                    
                    VStack(spacing: 15) {
                        Text("Save the World!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Choose a challenge to make the world better with LLMs")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: geometry.size.width > 800 ? 350 : 280), spacing: 20)
                        ],
                        spacing: 20
                    ) {
                        ForEach(MiniGame.allCases, id: \.self) { game in
                            MiniGameCard(
                                game: game,
                                isCompleted: gameState.completedMiniGames.contains(MiniGame.allCases.firstIndex(of: game)! + 1)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedGame = game
                                withAnimation(.spring()) {
                                    showingGameView = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Button {
                            withAnimation {
                                gameState.currentModule = 9
                            }
                        } label: {
                            Label("Finish Game", systemImage: "flag.checkered")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            showingReturnToReflection = true
                        } label: {
                            Label("Return to Reflection", systemImage: "arrow.left")
                                .font(.headline)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .frame(maxWidth: min(1000, geometry.size.width))
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
            .overlay {
                if showingGameView, let game = selectedGame {
                    Color(uiColor: .systemBackground)
                        .edgesIgnoringSafeArea(.all)
                        .overlay {
                            MiniGameView(
                                game: game,
                                gameState: gameState,
                                isPresented: $showingGameView
                            )
                            .frame(maxWidth: min(1000, geometry.size.width))
                            .frame(maxWidth: .infinity)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(), value: showingGameView)
        }
        .alert("Return to Reflection?", isPresented: $showingReturnToReflection) {
            Button("Yes") {
                withAnimation {
                    gameState.currentModule = 7
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You can come back anytime to complete the remaining challenges.")
        }
    }
}

struct MiniGameCard: View {
    let game: TrendingIssuesModule.MiniGame
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            
            ZStack {
                Circle()
                    .fill(game.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: game.icon)
                    .font(.title)
                    .foregroundColor(game.color)
            }
            
            
            VStack(spacing: 4) {
                Text(game.rawValue)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(game.theme)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(radius: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(game.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct MiniGameView: View {
    let game: TrendingIssuesModule.MiniGame
    @ObservedObject var gameState: GameState
    @Binding var isPresented: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                HStack {
                    Button {
                        withAnimation {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(game.theme)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(game.color.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 30) {
                        
                        VStack(spacing: 15) {
                            Text(game.rawValue)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(game.description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        
                        Group {
                            switch game {
                            case .audioRefinement:
                                AudioRefinementGame(gameState: gameState, dismiss: { isPresented = false })
                                    .padding(.horizontal)
                            case .energyReduction:
                                EnergyReductionGame(gameState: gameState, dismiss: { isPresented = false })
                                    .frame(minHeight: geometry.size.height * 0.7)
                            case .safeGuard:
                                SafeGuardGame(gameState: gameState, dismiss: { isPresented = false })
                                    .frame(minHeight: geometry.size.height * 0.6)
                            }
                        }
                        .frame(maxWidth: min(1000, geometry.size.width))
                        .frame(maxWidth: .infinity)
                        
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 1)
                }
            }
        }
    }
}

#Preview {
    TrendingIssuesModule(gameState: GameState())
} 
