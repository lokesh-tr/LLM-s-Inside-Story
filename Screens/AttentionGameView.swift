import SwiftUI

struct AttentionGameView: View {
    let onComplete: () -> Void
    @ObservedObject var gameState: GameState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var currentQuestion = 0
    @State private var showingFeedback = false
    @State private var isCorrect = false
    @State private var selectedHead: AttentionHead?
    @State private var showingExplanation = false
    
    private let questions = [
        AttentionQuestion(
            sentence: "The small cat chases the red ball",
            connection: AttentionConnection(
                from: "small",
                to: "cat",
                head: .emotions
            ),
            explanation: "Adjectives like 'small' express feelings or qualities about the noun 'cat'. I use my emotions head to understand these descriptive connections! 😊"
        ),
        AttentionQuestion(
            sentence: "She reads her favorite books daily",
            connection: AttentionConnection(
                from: "reads",
                to: "books",
                head: .verbs
            ),
            explanation: "The action 'reads' is connected to the object 'books'. My verbs head helps me understand what actions are being performed! 📚"
        ),
        AttentionQuestion(
            sentence: "The boy and his dog play together",
            connection: AttentionConnection(
                from: "boy",
                to: "dog",
                head: .relationships
            ),
            explanation: "There's a relationship between 'boy' and 'dog' showing possession. My relationships head helps me understand how things are connected! 🤝"
        ),
        AttentionQuestion(
            sentence: "The bright sun warms the earth",
            connection: AttentionConnection(
                from: "sun",
                to: "earth",
                head: .nouns
            ),
            explanation: "Both 'sun' and 'earth' are nouns - things or objects. My nouns head helps me understand what things are interacting! ☀️"
        )
    ]
    
    var currentQuestionItem: AttentionQuestion {
        questions[currentQuestion]
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isPad = horizontalSizeClass == .regular
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Color.clear
                        .frame(height: 60)
                    
                    
                    
                    
                    
                    HStack {
                        Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                        
                        VStack(spacing: 24) {
                            TitleProgressView(currentQuestion: currentQuestion, questionCount: questions.count, isPad: isPad)
                            QuestionView(currentQuestion: currentQuestionItem, isPad: isPad)
                            ThoughtBubbleView(
                                showingExplanation: showingFeedback,
                                explanation: showingFeedback ? (
                                    isCorrect ? "That's correct! 🎉\n\n\(currentQuestionItem.explanation)" : "Not quite right... 🤔\n\n\(currentQuestionItem.explanation)"
                                ) : nil,
                                isPad: isPad
                            )
                            AttentionHeadOptionsView(selectedHead: $selectedHead, showingFeedback: showingFeedback, isPad: isPad)
                            ActionButtonsView(
                                showingFeedback: showingFeedback,
                                isCorrect: isCorrect,
                                selectedHead: selectedHead,
                                isPad: isPad,
                                onTryAgain: {
                                    withAnimation {
                                        showingFeedback = false
                                        selectedHead = nil
                                    }
                                },
                                onCheckAnswer: checkAnswer
                            )
                        }
                        .padding()
                        .padding(.top, 32)
                        
                        Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
    
    private func checkAnswer() {
        if showingFeedback {
            
            withAnimation {
                if currentQuestion < questions.count - 1 {
                    currentQuestion += 1
                    showingFeedback = false
                    selectedHead = nil
                } else {
                    
                    gameState.completeModule(3)
                    onComplete()
                }
            }
        } else {
            
            withAnimation {
                isCorrect = selectedHead == currentQuestionItem.connection.head
                
                gameState.updateModuleScore(
                    points: isCorrect ? 25 : 0,
                    forModule: 3
                )
                showingFeedback = true
            }
        }
    }
}



struct TitleProgressView: View {
    let currentQuestion: Int
    let questionCount: Int
    let isPad: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Test Your Understanding")
                .font(isPad ? .largeTitle : .title)
                .fontWeight(.bold)
            
            ProgressDots(
                currentStep: currentQuestion,
                stepCount: questionCount,
                isPad: isPad
            )
        }
        .padding(.top)
    }
}

struct QuestionView: View {
    let currentQuestion: AttentionQuestion
    let isPad: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Identify the type of attention between the highlighted words:")
                .font(isPad ? .title3 : .body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            VStack {
                HighlightedSentenceView(
                    sentence: currentQuestion.sentence,
                    connection: currentQuestion.connection
                )
                .frame(height: isPad ? 200 : 160)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .secondarySystemBackground))
            }
        }
        .padding(.horizontal)
    }
}



























struct AttentionHeadOptionsView: View {
    @Binding var selectedHead: AttentionHead?
    let showingFeedback: Bool
    let isPad: Bool
    
    var body: some View {
        VStack(spacing: isPad ? 16 : 12) {
            ForEach(AttentionHead.allCases, id: \.self) { head in
                AttentionHeadButton(
                    head: head,
                    isSelected: selectedHead == head,
                    action: {
                        withAnimation {
                            selectedHead = head
                        }
                    }
                )
            }
        }
        .padding(.horizontal)
        .disabled(showingFeedback)
        .opacity(showingFeedback ? 0.6 : 1)
    }
}

struct ActionButtonsView: View {
    let showingFeedback: Bool
    let isCorrect: Bool
    let selectedHead: AttentionHead?
    let isPad: Bool
    let onTryAgain: () -> Void
    let onCheckAnswer: () -> Void
    
    var body: some View {
        Group {
            if showingFeedback {
                if isCorrect {
                    nextButton
                } else {
                    HStack(spacing: isPad ? 16 : 12) {
                        tryAgainButton
                        nextButton
                    }
                }
            } else {
                checkAnswerButton
            }
        }
        .padding(.horizontal)
    }
    
    private var tryAgainButton: some View {
        Button(action: onTryAgain) {
            Label("Try Again", systemImage: "arrow.counterclockwise")
                .font(isPad ? .title3 : .headline)
        }
        .buttonStyle(.prominent)
        .controlSize(isPad ? .large : .regular)
    }
    
    private var nextButton: some View {
        Button(action: onCheckAnswer) {
            Label("Next Question", systemImage: "arrow.right")
                .font(isPad ? .title3 : .headline)
        }
        .buttonStyle(.bordered)
        .controlSize(isPad ? .large : .regular)
        .tint(.blue)
    }
    
    private var checkAnswerButton: some View {
        Button(action: onCheckAnswer) {
            Label("Check Answer", systemImage: "checkmark")
                .font(isPad ? .title3 : .headline)
        }
        .buttonStyle(.bordered)
        .controlSize(isPad ? .large : .regular)
        .disabled(selectedHead == nil)
        .opacity(selectedHead == nil ? 0.6 : 1)
    }
}

struct AttentionQuestion {
    let sentence: String
    let connection: AttentionConnection
    let explanation: String
}

@preconcurrency
struct HighlightedSentenceView: View, Sendable {
    let sentence: String
    let connection: AttentionConnection
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var words: [String] {
        sentence.split(separator: " ").map(String.init)
    }
    
    var body: some View {
        let isPad = horizontalSizeClass == .regular
        let wordsArray = words // Capture the words array
        
        GeometryReader { geometry in
            var width = CGFloat.zero
            var height = CGFloat.zero
            var lastHeight = CGFloat.zero
            
            ZStack(alignment: .topLeading) {
                ForEach(wordsArray.indices, id: \.self) { index in
                    WordView(
                        word: wordsArray[index],
                        backgroundColor: highlightColor(for: wordsArray[index]),
                        isPad: isPad
                    )
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= lastHeight
                        }
                        lastHeight = dimension.height
                        let result = width
                        if index == wordsArray.count - 1 {
                            width = 0
                        } else {
                            width -= dimension.width + (isPad ? 16 : 12)
                        }
                        return result
                    }
                    .alignmentGuide(.top) { dimension in
                        let result = height
                        if index == wordsArray.count - 1 {
                            height = 0
                        }
                        return result
                    }
                    .padding(.trailing, isPad ? 16 : 12)
                    .padding(.bottom, isPad ? 16 : 12)
                }
            }
        }
    }
    
    private func highlightColor(for word: String) -> Color {
        if word == connection.from || word == connection.to {
            return connection.head.color.opacity(0.15)
        }
        return Color(.systemGray6)
    }
}



extension PrimitiveButtonStyle where Self == BorderedProminentButtonStyle {
    static var prominent: BorderedProminentButtonStyle {
        BorderedProminentButtonStyle()
    }
}

#Preview {
    AttentionGameView(
        onComplete: {
            print("Game complete!")
        },
        gameState: GameState()
    )
} 
