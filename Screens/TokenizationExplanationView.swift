import SwiftUI

struct TokenizationExplanationView: View {
    @ObservedObject var state: TokenizationState
    @ObservedObject var gameState: GameState
    @State private var selectedTokens: Set<UUID> = []
    @State private var selectedRule: MergeRule?
    @State private var showingHint = false
    @State private var showingExplanation = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            
                            HStack {
                                ProgressDots(
                                    currentStep: state.currentStep,
                                    stepCount: state.learningSteps.count,
                                    isPad: horizontalSizeClass == .regular
                                )
                                Spacer()
                                SkipModuleButton(gameState: gameState, currentModule: 2)
                            }
                            .padding(.horizontal)
                            
                            
                            AnimatedTitle(
                                title: "Step \(state.currentStep + 1): Learning to Read",
                                subtitle: state.learningSteps[state.currentStep],
                                isPad: horizontalSizeClass == .regular
                            )
                            .padding(.horizontal)
                            
                            
                            ThoughtBubbleView(
                                showingExplanation: showingExplanation,
                                explanation: selectedRule?.explanation,
                                isPad: horizontalSizeClass == .regular
                            )
                            
                            
                            if horizontalSizeClass == .regular {
                                TokenizationIPadLayout(
                                    state: state,
                                    selectedTokens: $selectedTokens,
                                    selectedRule: $selectedRule,
                                    showingHint: $showingHint,
                                    showingExplanation: $showingExplanation,
                                    onTryMerge: tryApplyMergeRule
                                )
                            } else {
                                TokenizationIPhoneLayout(
                                    state: state,
                                    selectedTokens: $selectedTokens,
                                    selectedRule: $selectedRule,
                                    showingHint: $showingHint,
                                    showingExplanation: $showingExplanation,
                                    onTryMerge: tryApplyMergeRule
                                )
                            }
                            
                            
                            NavigationButtonsView(
                                state: state,
                                gameState: gameState,
                                selectedTokens: $selectedTokens,
                                selectedRule: $selectedRule,
                                isPad: horizontalSizeClass == .regular
                            )
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                    }
                }
                .padding(.vertical)
                .frame(minHeight: geometry.size.height)
            }
        }
        .onAppear {
            state.resetToStep(0)
            state.updateAvailableRules()
        }
        .alert("How to Help Me Learn", isPresented: $showingHint) {
            Button("Got it!") {}
        } message: {
            Text("1. Select the letters I should learn about (you can select from both areas)\n2. Tap a rule that matches what you selected\n3. Watch how I understand the text!")
        }
    }
    
    private func tryApplyMergeRule() {
        state.tryMerge(selectedTokens: selectedTokens, gameState: gameState)
        selectedTokens.removeAll()
    }
}



struct TokenizationIPadLayout: View {
    let state: TokenizationState
    @Binding var selectedTokens: Set<UUID>
    @Binding var selectedRule: MergeRule?
    @Binding var showingHint: Bool
    @Binding var showingExplanation: Bool
    let onTryMerge: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            
            VStack(alignment: .leading, spacing: 24) {
                tokenSection(title: "Text I'm Learning", tokens: state.inputTokens)
                tokenSection(title: "What I Understand", tokens: state.outputTokens)
            }
            .frame(maxWidth: .infinity)
            
            
            MergeRulesSection(
                rules: state.mergeRules,
                selectedRule: $selectedRule,
                showingHint: $showingHint,
                showingExplanation: $showingExplanation,
                onTryMerge: onTryMerge
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
    
    private func tokenSection(title: String, tokens: [Token]) -> some View {
        TokenSection(
            title: title,
            tokens: tokens,
            selectedTokens: $selectedTokens,
            isPad: true
        )
    }
}

struct TokenizationIPhoneLayout: View {
    let state: TokenizationState
    @Binding var selectedTokens: Set<UUID>
    @Binding var selectedRule: MergeRule?
    @Binding var showingHint: Bool
    @Binding var showingExplanation: Bool
    let onTryMerge: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            TokenSection(
                title: "Text I'm Learning",
                tokens: state.inputTokens,
                selectedTokens: $selectedTokens,
                isPad: false
            )
            
            TokenSection(
                title: "What I Understand",
                tokens: state.outputTokens,
                selectedTokens: $selectedTokens,
                isPad: false
            )
            
            MergeRulesSection(
                rules: state.mergeRules,
                selectedRule: $selectedRule,
                showingHint: $showingHint,
                showingExplanation: $showingExplanation,
                onTryMerge: onTryMerge
            )
        }
    }
}

struct TokenSection: View {
    let title: String
    let tokens: [Token]
    @Binding var selectedTokens: Set<UUID>
    let isPad: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(isPad ? .title3.bold() : .headline)
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: isPad ? 12 : 8) {
                    ForEach(tokens) { token in
                        TokenView(
                            token: token,
                            isSelected: selectedTokens.contains(token.id)
                        ) {
                            withAnimation {
                                if selectedTokens.contains(token.id) {
                                    selectedTokens.remove(token.id)
                                } else {
                                    selectedTokens.insert(token.id)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .frame(minHeight: isPad ? 60 : 44)
            }
        }
    }
}

struct MergeRulesSection: View {
    let rules: [MergeRule]
    @Binding var selectedRule: MergeRule?
    @Binding var showingHint: Bool
    @Binding var showingExplanation: Bool
    let onTryMerge: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: isPad ? 16 : 12) {
            HStack {
                Text("What I've Learned")
                    .font(isPad ? .title3 : .headline)
                    .bold()
                
                Spacer()
                
                Button {
                    showingHint.toggle()
                } label: {
                    Label("Help me", systemImage: "questionmark.circle")
                        .font(isPad ? .title3 : .body)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            VStack(spacing: isPad ? 16 : 12) {
                ForEach(rules) { rule in
                    MergeRuleView(
                        rule: rule,
                        isSelected: selectedRule?.id == rule.id
                    ) {
                        withAnimation {
                            selectedRule = rule
                            showingExplanation = true
                            onTryMerge()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showingExplanation = false
                            }
                        }
                    }
                }
            }
            .frame(minHeight: isPad ? 120 : 100)
            .padding(.horizontal)
        }
    }
    
    private var isPad: Bool {
        horizontalSizeClass == .regular
    }
}

struct NavigationButtonsView: View {
    let state: TokenizationState
    let gameState: GameState
    @Binding var selectedTokens: Set<UUID>
    @Binding var selectedRule: MergeRule?
    let isPad: Bool
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 20) {
                
                Button {
                    withAnimation {
                        state.resetToStep(state.currentStep)
                        selectedTokens.removeAll()
                        selectedRule = nil
                    }
                } label: {
                    Label("Try Again", systemImage: "arrow.counterclockwise")
                        .font(isPad ? .title3 : .headline)
                }
                .buttonStyle(.bordered)
                .controlSize(isPad ? .large : .regular)
                
                
                if state.canAdvanceToNextStep() {
                    Button {
                        withAnimation {
                            state.resetToStep(state.currentStep + 1)
                            selectedTokens.removeAll()
                            selectedRule = nil
                        }
                    } label: {
                        Label("Next Step", systemImage: "arrow.right")
                            .font(isPad ? .title3 : .headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(isPad ? .large : .regular)
                }
                
                
                if state.currentStep == state.learningSteps.count - 1 && !state.outputTokens.isEmpty {
                    Button {
                        withAnimation {
                            gameState.currentModule = 3
                        }
                    } label: {
                        Label("Next Module", systemImage: "arrow.right.circle.fill")
                            .font(isPad ? .title3 : .headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(isPad ? .large : .regular)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        TokenizationExplanationView(state: TokenizationState(), gameState: GameState())
    }
} 
