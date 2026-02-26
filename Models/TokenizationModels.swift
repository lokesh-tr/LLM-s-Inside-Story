import Foundation

struct Token: Identifiable, Equatable {
    let id = UUID()
    let characters: [Character]
    var text: String { String(characters) }
    var isHighlighted = false
}

struct MergeRule: Identifiable, Equatable {
    let id = UUID()
    let from: String
    let to: String
    let description: String
    let explanation: String
}

class TokenizationState: ObservableObject {
    @Published var currentStep = 0
    @Published var inputTokens: [Token] = []
    @Published var mergeRules: [MergeRule] = []
    @Published var outputTokens: [Token] = []
    
    let learningSteps = [
        "I start by seeing text as individual letters, just like a baby learning to read...",
        "Then, I learn that some letters frequently appear together to make sounds...",
        "Next, I discover common patterns that appear at the start or end of words...",
        "Finally, I can recognize whole words and understand how they're built!"
    ]
    
    let stepExamples = [
        "cat",         
        "book",        
        "playing",     
        "happiness"    
    ]
    
    
    private let predefinedMergeRules = [
        
        MergeRule(
            from: "c a",
            to: "ca",
            description: "First two letters",
            explanation: "Just like you learned to read, I start by combining basic letters. 'c' and 'a' often go together!"
        ),
        MergeRule(
            from: "ca t",
            to: "cat",
            description: "Complete word",
            explanation: "Now I can see this makes a simple word - cat! It's a small animal that says meow 🐱"
        ),
        
        
        MergeRule(
            from: "o o",
            to: "oo",
            description: "Double letters",
            explanation: "I notice that 'oo' appears in many words and makes a special sound, like in 'moon' and 'food'"
        ),
        MergeRule(
            from: "b oo",
            to: "boo",
            description: "Start with double letters",
            explanation: "Let's combine 'b' with 'oo' to start forming our word!"
        ),
        MergeRule(
            from: "boo k",
            to: "book",
            description: "Complete word",
            explanation: "Adding 'k' completes the word! A book is something you read 📚"
        ),
        
        
        MergeRule(
            from: "p l",
            to: "pl",
            description: "Starting blend",
            explanation: "Many action words start with 'pl' like 'play', 'plus', 'plan'"
        ),
        MergeRule(
            from: "pl a y",
            to: "play",
            description: "Action word",
            explanation: "We've made the base word 'play' - it means to have fun!"
        ),
        MergeRule(
            from: "i n g",
            to: "ing",
            description: "Action ending",
            explanation: "When I see 'ing' at the end, it usually means someone is doing something"
        ),
        MergeRule(
            from: "play ing",
            to: "playing",
            description: "Complete word",
            explanation: "Adding 'ing' shows the action is happening now - someone is playing! 🎮"
        ),
        
        
        MergeRule(
            from: "h a p p",
            to: "happ",
            description: "Root word start",
            explanation: "This is the start of our word that means feeling good!"
        ),
        MergeRule(
            from: "happ i",
            to: "happi",
            description: "Complete root",
            explanation: "Adding 'i' completes our root word 'happy'!"
        ),
        MergeRule(
            from: "n e s s",
            to: "ness",
            description: "Feeling suffix",
            explanation: "These letters combine to make 'ness', which turns words into feelings!"
        ),
        MergeRule(
            from: "happi ness",
            to: "happiness",
            description: "Complete word",
            explanation: "Adding 'ness' turns 'happy' into the feeling of being happy - happiness! 😊"
        )
    ]
    
    init() {
        resetToStep(0)
    }
    
    func resetToStep(_ step: Int) {
        currentStep = step
        inputTokens = Array(stepExamples[step]).map { Token(characters: [$0]) }
        outputTokens = []
        updateAvailableRules()
    }
    
    func applyMergeRule(_ rule: MergeRule, toTokens tokens: [Token]) -> [Token]? {
        let text = tokens.map { $0.text }.joined(separator: " ")
        guard text == rule.from else { return nil }
        return [Token(characters: Array(rule.to))]
    }
    
    func updateScore(correct: Bool, gameState: GameState) {
        let points = correct ? GameState.correctAnswerScore : GameState.incorrectAnswerPenalty
        gameState.updateModuleScore(points: points, forModule: 2)
    }
    
    func canAdvanceToNextStep() -> Bool {
        let completeWord = stepExamples[currentStep]
        return outputTokens.contains { $0.text == completeWord } && currentStep < learningSteps.count - 1
    }
    
    func updateAvailableRules() {
        
        let stepRules: [MergeRule]
        switch currentStep {
        case 0: 
            stepRules = Array(predefinedMergeRules[0...1])
        case 1: 
            stepRules = Array(predefinedMergeRules[2...4])
        case 2: 
            stepRules = Array(predefinedMergeRules[5...8])
        case 3: 
            stepRules = Array(predefinedMergeRules[9...12])
        default:
            stepRules = []
        }
        
        
        mergeRules = stepRules.filter { rule in
            let parts = rule.from.components(separatedBy: " ")
            
            
            for part in parts {
                let existsInInput = inputTokens.contains { $0.text == part }
                let existsInOutput = outputTokens.contains { $0.text == part }
                
                if !existsInInput && !existsInOutput {
                    return false
                }
            }
            
            return true
        }
    }
    
    func tryMerge(selectedTokens: Set<UUID>, gameState: GameState? = nil) {
        let selectedInputTokens = inputTokens.filter { selectedTokens.contains($0.id) }
        let selectedOutputTokens = outputTokens.filter { selectedTokens.contains($0.id) }
        
        
        let combinations = [
            selectedInputTokens + selectedOutputTokens,
            selectedOutputTokens + selectedInputTokens
        ]
        
        for tokensToMerge in combinations {
            guard !tokensToMerge.isEmpty else { continue }
            
            
            let pattern = tokensToMerge.map { $0.text }.joined(separator: " ")
            
            
            if let rule = mergeRules.first(where: { $0.from == pattern }),
               let mergedTokens = applyMergeRule(rule, toTokens: tokensToMerge) {
                
                
                inputTokens.removeAll { selectedTokens.contains($0.id) }
                outputTokens.removeAll { selectedTokens.contains($0.id) }
                
                
                outputTokens.append(contentsOf: mergedTokens)
                
                
                if let gameState = gameState {
                    updateScore(correct: true, gameState: gameState)
                }
                
                
                if canAdvanceToNextStep() {
                    gameState?.completeModule(2)
                }
                
                
                updateAvailableRules()
                return
            }
        }
        
        
        if let gameState = gameState {
            updateScore(correct: false, gameState: gameState)
        }
    }
} 