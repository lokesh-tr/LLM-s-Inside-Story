import SwiftUI

struct NextWordPredictionModule: View {
    @StateObject private var state = NextWordPredictionState()
    @ObservedObject var gameState: GameState
    @State private var currentScreen = 1
    @State private var showingSuccessAlert = false
    
    var body: some View {
        ZStack {
            if currentScreen == 1 {
                ContextDemonstrationView(onContinue: {
                    withAnimation {
                        currentScreen = 2
                    }
                })
            } else {
                NextWordPredictionGameView(
                    state: state,
                    gameState: gameState,
                    showingSuccessAlert: $showingSuccessAlert,
                    onComplete: {
                        withAnimation {
                            gameState.completeModule(6)  
                            gameState.currentModule = 7  
                        }
                    }
                )
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing),
                              removal: .move(edge: .leading)))
        .overlay(alignment: .topTrailing) {
            SkipModuleButton(gameState: gameState, currentModule: 6)
                .padding()
        }
    }
}

struct ContextDemonstrationView: View {
    let onContinue: () -> Void
    @State private var showContext = false
    @State private var currentExample = 0
    
    let examples = [
        (
            context: "The weather today is sunny with clear skies and a gentle breeze.",
            question: "What's the temperature likely to be?",
            withContext: "Based on the sunny weather and clear skies, it's likely to be warm.",
            withoutContext: "Without context about the weather conditions, I cannot predict the temperature."
        ),
        (
            context: "Sarah has been studying medicine for six years and recently completed her residency.",
            question: "What is Sarah's profession?",
            withContext: "Sarah is most likely a doctor, given her medical education and residency.",
            withoutContext: "Without information about Sarah's background, I cannot determine her profession."
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                HStack {
                    Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                    
                    VStack(spacing: 24) {
                        
                        Color.clear
                            .frame(height: 60)
                        
                        Text("The Power of Context")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle("Show Context to LLM", isOn: $showContext.animation(.spring()))
                                .font(.headline)
                            
                            if showContext {
                                Text("Context:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .transition(.opacity.combined(with: .move(edge: .leading)))
                                Text(examples[currentExample].context)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(15)
                        .animation(.spring(), value: showContext)
                        
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Question:")
                                .font(.headline)
                            Text(examples[currentExample].question)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(10)
                            
                            Text("LLM's Answer:")
                                .font(.headline)
                            Text(showContext ? examples[currentExample].withContext : examples[currentExample].withoutContext)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                                .animation(.spring(), value: showContext)
                                .transition(.opacity)
                        }
                        .padding()
                        
                        
                        ModelThoughtBubble(
                            thought: showContext ? 
                                "With context, I can make informed predictions! 🎯" :
                                "Without context, I can only make vague guesses... 🤔"
                        )
                        .padding(.horizontal)
                        .animation(.spring(), value: showContext)
                        .transition(.scale)
                        
                        
                        if currentExample < examples.count - 1 {
                            Button(action: {
                                withAnimation {
                                    currentExample += 1
                                    showContext = false  
                                }
                            }) {
                                Text("Next Example")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding()
                        } else {
                            Button(action: onContinue) {
                                Text("Let's Practice!")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                    .frame(maxWidth: 800)
                    .padding()
                    
                    Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                }
                .frame(minHeight: geometry.size.height)
                .padding(.bottom, 30)
            }
        }
    }
}

struct NextWordPredictionGameView: View {
    @ObservedObject var state: NextWordPredictionState
    @ObservedObject var gameState: GameState
    @Binding var showingSuccessAlert: Bool
    let onComplete: () -> Void
    
    @State private var showingFeedback = false
    @State private var isCorrect = false
    
    private var isContextCorrect: Bool {
        state.selectedText.lowercased().contains(state.currentExample.relevantContext.lowercased())
    }
    
    private var displayedAnswer: String {
        if isContextCorrect {
            return state.currentExample.answer + " " + state.currentExample.nextWord
        }
        return state.currentExample.answer + "..."
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                HStack {
                    Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                    
                    VStack(spacing: 25) {
                        
                        Color.clear
                            .frame(height: 60)
                        
                        Text("Help Me Complete the Answer!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        
                        ProgressIndicator(progress: state.progress, color: .blue)
                            .frame(height: 8)
                            .padding(.horizontal)
                        
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Context:")
                                .font(.headline)
                            
                            
                            HStack(spacing: 6) {
                                Image(systemName: "hand.tap")
                                    .foregroundColor(.blue)
                                Text("Touch and hold any text below to select")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Image(systemName: "arrow.down")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            
                            SelectableText(
                                text: state.currentExample.context,
                                selectedText: $state.selectedText
                            )
                        }
                        .padding(.horizontal)
                        
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Question:")
                                .font(.headline)
                            Text(state.currentExample.question)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            
                            Text("Answer:")
                                .font(.headline)
                            Text(displayedAnswer)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                                .animation(.spring(), value: displayedAnswer)
                        }
                        .padding(.horizontal)
                        
                        
                        ModelThoughtBubble(
                            thought: state.selectedText.isEmpty ?
                                "Help me find the relevant context to complete the answer! 🔍" :
                                isContextCorrect ?
                                    "Perfect! Now I can predict the next word! 🎯" :
                                    "Hmm... that's not quite the right part. Try another section! 🤔"
                        )
                        .padding(.horizontal)
                        .animation(.spring(), value: state.selectedText)
                        .animation(.spring(), value: isContextCorrect)
                        
                        
                        if isContextCorrect {
                            Button(action: {
                                let totalExamples = state.examples.count
                                let pointsPerExample = 100 / totalExamples
                                gameState.updateModuleScore(points: pointsPerExample, forModule: 6)
                                
                                if state.nextExample() {
                                    state.selectedText = ""
                                } else {
                                    showingSuccessAlert = true
                                    onComplete()
                                }
                            }) {
                                Text(state.currentExampleIndex < state.examples.count - 1 ? "Next Question" : "Complete Module")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: 800)
                    .padding()
                    
                    Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                }
                .frame(minHeight: geometry.size.height)
                .padding(.bottom, 30)
            }
        }
        .alert("Congratulations!", isPresented: $showingSuccessAlert) {
            Button("Continue", role: .cancel) { }
        } message: {
            Text("You've mastered next-word prediction! Time to move on to the next challenge.")
        }
    }
}

#Preview("Next-Word Prediction Module") {
    NextWordPredictionModule(gameState: GameState())
}

#Preview("Context Demonstration") {
    ContextDemonstrationView(onContinue: {})
}

#Preview("Game View") {
    NextWordPredictionGameView(
        state: NextWordPredictionState(),
        gameState: GameState(),
        showingSuccessAlert: .constant(false),
        onComplete: {}
    )
} 