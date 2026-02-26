import SwiftUI

struct PretrainingTestView: View {
    @ObservedObject var state: PretrainingState
    @ObservedObject var gameState: GameState
    @State private var showCongratulations = false
    @State private var showRetryMessage = false
    @State private var isRunningTest = false
    @State private var displayedKnowledgeScore: Double = 0
    @State private var testTimer: Timer?
    let onComplete: () -> Void
    let onRetry: () -> Void
    
    private func runTest() {
        isRunningTest = true
        displayedKnowledgeScore = 0
        
        withAnimation(.easeInOut(duration: 2.0)) {
            showCongratulations = false
            showRetryMessage = false
        }
        
        let targetScore = state.modelKnowledgeScore
        
        // Animate score over 1.8 seconds
        withAnimation(.easeInOut(duration: 1.8)) {
            displayedKnowledgeScore = targetScore
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let (passed, pointsToAdd) = state.getTestResults()
            
            withAnimation(.spring()) {
                if passed {
                    showCongratulations = true
                    
                    gameState.updateModuleScore(points: pointsToAdd, forModule: 4)
                    gameState.completeModule(4)
                } else {
                    showRetryMessage = true
                }
                isRunningTest = false
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                
                ScrollView {
                    HStack {
                        Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                        
                        VStack(spacing: 24) {
                            
                            Color.clear
                                .frame(height: 60)
                            
                            Text("Test Your Model")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            
                            VStack(spacing: 16) {
                                ModelView(size: 150, score: displayedKnowledgeScore)
                                    .shadow(color: .blue.opacity(0.2), radius: 20)
                                
                                Text("Current Knowledge: \(Int(displayedKnowledgeScore))%")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            
                            VStack(spacing: 16) {
                                Text("The model needs at least 85% knowledge to be useful.")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                
                                if isRunningTest {
                                    HStack {
                                        ProgressView()
                                            .tint(.secondary)
                                        Text("Testing Knowledge...")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            
                            Button {
                                onRetry()
                            } label: {
                                Text("← Back to Training")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.bottom)
                        }
                        .frame(maxWidth: geometry.size.width > 800 ? 800 : .infinity)
                        .padding()
                        .frame(minHeight: geometry.size.height)
                        
                        Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                    }
                }
                
                
                if showRetryMessage {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack(spacing: 24) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange)
                        
                        Text("More Training Needed")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("The model needs more knowledge sources to be effective. Let's go back and connect more!")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Button {
                            onRetry()
                        } label: {
                            Text("Back to Training →")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top)
                    }
                    .padding(32)
                    .frame(maxWidth: geometry.size.width > 800 ? 800 : .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(32)
                    .transition(.scale.combined(with: .opacity))
                }
                
                
                if showCongratulations {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.green)
                        
                        Text("Great job!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        VStack(spacing: 8) {
                            Text("The model has enough knowledge to be useful.")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.8))
                            
                            let (_, pointsToAdd) = state.getTestResults()
                            Text("+\(pointsToAdd) points")
                                .font(.title3)
                                .foregroundStyle(.green)
                                .padding(.top, 4)
                        }
                        
                        Button {
                            onComplete()
                        } label: {
                            Text("Continue →")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top)
                    }
                    .padding(28)
                    .frame(maxWidth: geometry.size.width > 800 ? 800 : .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(32)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            runTest()
        }
    }
}

#Preview {
    PretrainingTestView(
        state: PretrainingState(),
        gameState: GameState(),
        onComplete: {},
        onRetry: {}
    )
}
