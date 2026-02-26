import SwiftUI

struct PredictionExample {
    let context: String
    let question: String
    let answer: String
    let relevantContext: String
    let nextWord: String
    var selectedText: String = ""
    var isCorrect: Bool = false
}

class NextWordPredictionState: ObservableObject {
    @Published var currentExampleIndex: Int = 0
    @Published var examples: [PredictionExample] = [
        PredictionExample(
            context: "The weather forecast shows heavy rain and strong winds approaching from the north. The temperature will drop significantly overnight.",
            question: "What should people prepare for?",
            answer: "People should prepare for cold",
            relevantContext: "temperature will drop significantly",
            nextWord: "weather"
        ),
        PredictionExample(
            context: "The young musician practiced piano for hours every day, mastering complex pieces and developing perfect pitch. Her dedication was remarkable.",
            question: "What level of skill did she achieve?",
            answer: "She achieved a level of",
            relevantContext: "mastering complex pieces and developing perfect pitch",
            nextWord: "excellence"
        ),
        PredictionExample(
            context: "The new restaurant uses only organic ingredients sourced from local farms. Their menu changes based on seasonal availability.",
            question: "What kind of food do they serve?",
            answer: "They serve fresh and",
            relevantContext: "organic ingredients sourced from local farms",
            nextWord: "seasonal"
        )
    ]
    
    @Published var selectedText: String = ""
    
    func checkAnswer() -> Bool {
        let currentExample = examples[currentExampleIndex]
        let isCorrect = selectedText.lowercased().contains(currentExample.relevantContext.lowercased())
        examples[currentExampleIndex].selectedText = selectedText
        examples[currentExampleIndex].isCorrect = isCorrect
        return isCorrect
    }
    
    func nextExample() -> Bool {
        if currentExampleIndex < examples.count - 1 {
            currentExampleIndex += 1
            selectedText = ""
            return true
        }
        return false
    }
    
    var currentExample: PredictionExample {
        examples[currentExampleIndex]
    }
    
    var progress: Double {
        Double(currentExampleIndex) / Double(examples.count - 1)
    }
} 