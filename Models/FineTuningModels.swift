import SwiftUI

class FineTuningState: ObservableObject {
    @Published var parameters: [String: Double] = [
        "promptLength": 0.5,      
        "temperature": 0.5,       
        "trainingSteps": 0.5      
    ]
    
    let expectedOutputs = [
        [
            "The cat sleeps on couch.",
            "The dog plays in yard.",
            "The bird sings in tree."
        ],
        [
            "The sun shines bright.",
            "The flowers bloom here.",
            "The grass looks fresh."
        ],
        [
            "Kids read their books.",
            "Teacher writes notes.",
            "Class stays quiet."
        ]
    ]
    
    let garbledOutputs = [
        [
            "cat slep on couch",
            "dog do stuff yard",
            "bird noiz tree"
        ],
        [
            "sun bright here",
            "flowerz grow now",
            "grass lookz ok"
        ],
        [
            "kidz look bookz",
            "teachr writez thing",
            "room iz quiet"
        ]
    ]
    
    @Published var currentOutputs: [String] = []
    @Published var expectedOutputs_current: [String] = []
    @Published var outputMatchScore: Double = 0.0
    @Published var currentExampleIndex: Int = 0
    @Published var modelThought: String = "I'm not sure about the details... Everything seems fuzzy."
    
    init() {
        resetForCurrentExample()
    }
    
    private func resetForCurrentExample() {
        currentOutputs = garbledOutputs[currentExampleIndex]
        expectedOutputs_current = expectedOutputs[currentExampleIndex]
    }
    
    func updateParameters(_ parameter: String, value: Double) {
        parameters[parameter] = value
        updateOutput()
    }
    
    private func updateOutput() {
        let promptLength = parameters["promptLength"] ?? 0.5
        let temperature = parameters["temperature"] ?? 0.5
        let trainingSteps = parameters["trainingSteps"] ?? 0.5
        
        
        outputMatchScore = (promptLength * 0.3 + (1 - temperature) * 0.3 + trainingSteps * 0.4)
        
        
        var newOutputs: [String] = []
        for (garbled, expected) in zip(garbledOutputs[currentExampleIndex], expectedOutputs[currentExampleIndex]) {
            
            let output = transformText(
                original: garbled,
                target: expected,
                promptLength: promptLength,
                temperature: temperature,
                trainingSteps: trainingSteps
            )
            newOutputs.append(output)
        }
        currentOutputs = newOutputs
        
        
        updateModelThoughts(promptLength: promptLength, temperature: temperature, trainingSteps: trainingSteps)
    }
    
    private func transformText(original: String, target: String, promptLength: Double, temperature: Double, trainingSteps: Double) -> String {
        let quality = (promptLength * 0.3 + (1 - temperature) * 0.3 + trainingSteps * 0.4)
        
        if quality > 0.95 { return target }
        
        let origChars = Array(original)
        let targetChars = Array(target)
        var result = ""
        
        
        let correctCount = Int(Double(targetChars.count) * quality)
        
        for i in 0..<max(origChars.count, targetChars.count) {
            if i < correctCount && i < targetChars.count {
                
                result.append(targetChars[i])
            } else if i < origChars.count {
                
                let char = origChars[i]
                if quality > 0.3 {
                    
                    switch char {
                    case "z": result.append("s")
                    case "i": result.append(quality > 0.6 ? "i" : "y")
                    default: result.append(char)
                    }
                } else {
                    result.append(char)
                }
            }
        }
        
        
        if quality > 0.8 && result.count < target.count {
            result += target[target.index(target.startIndex, offsetBy: result.count)...]
        }
        
        
        if quality > 0.6 {
            result = result.prefix(1).uppercased() + result.dropFirst()
            if !result.hasSuffix(".") { result += "." }
        }
        
        return result
    }
    
    private func updateModelThoughts(promptLength: Double, temperature: Double, trainingSteps: Double) {
        let quality = (promptLength * 0.3 + (1 - temperature) * 0.3 + trainingSteps * 0.4)
        
        
        if promptLength < 0.8 && promptLength <= temperature && promptLength <= trainingSteps {
            modelThought = "I need more context to learn from... Try increasing the prompt length! 📚"
        } else if temperature > 0.2 && (1 - temperature) <= promptLength && (1 - temperature) <= trainingSteps {
            modelThought = "I'm being too random... Try lowering the temperature to make me more focused! 🎯"
        } else if trainingSteps < 0.8 && trainingSteps <= promptLength && (1 - temperature) >= trainingSteps {
            modelThought = "I need more practice... Try increasing the training steps! 🔄"
        }
        
        else if quality < 0.3 {
            modelThought = "Everything's too fuzzy. Start by increasing prompt length and training steps, then lower temperature. 🤔"
        } else if quality < 0.5 {
            modelThought = "Getting better! Keep adjusting the parameters. Lower temperature helps with accuracy. 📈"
        } else if quality < 0.7 {
            modelThought = "Good progress! Fine-tune the parameters - remember, high prompt length and training steps, low temperature! ⚡️"
        } else if quality < 0.9 {
            modelThought = "So close! Just need some minor tweaks to perfect the output. ✨"
        } else {
            modelThought = "Perfect! I'm now generating high-quality outputs! 🎉"
        }
    }
    
    func nextExample() {
        currentExampleIndex = (currentExampleIndex + 1) % expectedOutputs.count
        resetParameters()
    }
    
    func resetParameters() {
        parameters = [
            "promptLength": 0.5,
            "temperature": 0.5,
            "trainingSteps": 0.5
        ]
        resetForCurrentExample()
        updateOutput()
    }
}
