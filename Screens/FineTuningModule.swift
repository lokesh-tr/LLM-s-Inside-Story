import SwiftUI

struct FineTuningModule: View {
    @StateObject private var state = FineTuningState()
    @ObservedObject var gameState: GameState
    @State private var showingSuccessAlert = false
    
    var body: some View {
        FineTuningInteractionView(
            state: state,
            gameState: gameState,
            showingSuccessAlert: $showingSuccessAlert,
            onComplete: {
                withAnimation {
                    gameState.completeModule(5)
                    gameState.currentModule = 6  
                }
            }
        )
        .overlay(alignment: .topTrailing) {
            SkipModuleButton(gameState: gameState, currentModule: 5)
                .padding()
        }
    }
}

struct FineTuningInteractionView: View {
    @ObservedObject var state: FineTuningState
    @ObservedObject var gameState: GameState
    @Binding var showingSuccessAlert: Bool
    let onComplete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 15) {
                    
                    Color.clear
                        .frame(height: 60)
                    
                    VStack(spacing: 15) {
                        Text("Fine-Tune Your Model")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        
                        VStack(spacing: 8) {
                            Text("\(Int(state.outputMatchScore * 100))%")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(state.outputMatchScore > 0.8 ? .green : .orange)
                            
                            ProgressIndicator(
                                progress: state.outputMatchScore,
                                color: state.outputMatchScore > 0.8 ? .green : .orange
                            )
                            .frame(height: 6)
                        }
                        .padding(.horizontal)
                        
                        
                        ModelThoughtBubble(thought: state.modelThought)
                            .padding(.horizontal)
                        
                        
                        OutputComparisonView(
                            currentOutputs: state.currentOutputs,
                            expectedOutputs: state.expectedOutputs_current,
                            matchScore: state.outputMatchScore
                        )
                        
                        
                        VStack(spacing: 12) {
                            ForEach(Array(state.parameters.keys), id: \.self) { parameter in
                                ParameterSlider(
                                    name: parameter,
                                    value: .init(
                                        get: { state.parameters[parameter] ?? 0 },
                                        set: { state.parameters[parameter] = $0 }
                                    ),
                                    onChange: { state.updateParameters(parameter, value: $0) }
                                )
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        if state.outputMatchScore > 0.8 {
                            Button(action: {
                                let points = Int(state.outputMatchScore * 100)
                                gameState.updateModuleScore(points: points, forModule: 5)
                                showingSuccessAlert = true
                                onComplete()
                            }) {
                                Text("Complete Module")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: geometry.size.width > 800 ? 800 : .infinity)
                }
                .padding(.vertical)
                .frame(minHeight: geometry.size.height)
            }
        }
        .alert("Great Job!", isPresented: $showingSuccessAlert) {
            Button("Continue", role: .cancel) { }
        } message: {
            Text("You've successfully fine-tuned the model! Let's move on to the next module.")
        }
    }
}

#Preview("Fine-Tuning Module") {
    FineTuningModule(gameState: GameState())
}

#Preview("Interaction View") {
    FineTuningInteractionView(
        state: FineTuningState(),
        gameState: GameState(),
        showingSuccessAlert: .constant(false),
        onComplete: {}
    )
} 