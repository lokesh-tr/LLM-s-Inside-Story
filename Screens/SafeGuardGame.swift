import SwiftUI

@preconcurrency
struct SafeGuardGame: View {
    @ObservedObject var gameState: GameState
    @StateObject private var state = SafeGuardState()
    @State private var showingSuccessAlert = false
    @State private var selectedRange: NSRange?
    let dismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                
                HStack {
                    Text("Messages Protected: \(state.completedPrompts)/4")
                        .font(.headline)
                    Spacer()
                    Text("Score: \(state.score)%")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                
                VStack(spacing: 10) {
                    Text("Protect Personal Information")
                        .font(.headline)
                    
                    Text("Select sensitive information and tap 'Redact' to protect it")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                
                ZStack {
                    if !state.isTransitioning {
                        ScrollView {
                            RedactableTextView(
                                text: state.prompts[state.completedPrompts].text,
                                redactedRanges: state.redactedRanges,
                                selectedRange: $selectedRange
                            )
                            .frame(minHeight: 100)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                        .frame(maxHeight: 200)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                
                HStack(spacing: 20) {
                    
                    Button {
                        withAnimation {
                            state.redactedRanges = []
                            state.completedRedactions.remove(state.completedPrompts)
                            state.isCurrentPromptCompleted = false
                            selectedRange = nil
                        }
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    
                    Button {
                        if let range = selectedRange {
                            withAnimation {
                                state.redactedRanges.append(range)
                                selectedRange = nil
                            }
                        }
                    } label: {
                        Label("Redact", systemImage: "eye.slash")
                            .font(.headline)
                            .foregroundColor(selectedRange != nil ? .white : .gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedRange != nil ? Color.red : Color.red.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .disabled(selectedRange == nil)
                    
                    
                    Button {
                        let score = state.checkRedactions()
                        print("Score: \(score)%") 
                        
                        if score >= 80 {
                            state.isCurrentPromptCompleted = true
                            state.completedRedactions.insert(state.completedPrompts)
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if state.completedPrompts + 1 == state.prompts.count {
                                    
                                    gameState.updateModuleScore(points: 1000, forModule: 8)
                                    gameState.completeMiniGame(3)
                                    showingSuccessAlert = true
                                } else {
                                    
                                    state.nextPrompt()
                                }
                            }
                        }
                    } label: {
                        Label("Submit", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .alert("Privacy Protected!", isPresented: $showingSuccessAlert) {
                Button("Continue") {
                    dismiss()
                }
            } message: {
                Text("You've successfully protected user privacy by identifying and redacting personal information!\n\nPoints awarded: 1000")
            }
        }
    }
}

@preconcurrency
struct RedactableTextView: UIViewRepresentable {
    let text: String
    let redactedRanges: [NSRange]
    @Binding var selectedRange: NSRange?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = .systemFont(ofSize: 16)
        textView.text = text  
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        let attributedString = NSMutableAttributedString(string: text)
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: text.count))
        
        
        for range in redactedRanges {
            attributedString.addAttribute(.backgroundColor, value: UIColor.black, range: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: range)
        }
        
        textView.attributedText = attributedString
        
        
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(fixedWidth, newSize.width), height: newSize.height)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @preconcurrency
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: RedactableTextView
        
        init(_ parent: RedactableTextView) {
            self.parent = parent
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            if let range = textView.selectedTextRange {
                let location = textView.offset(from: textView.beginningOfDocument, to: range.start)
                let length = textView.offset(from: range.start, to: range.end)
                if length > 0 {
                    parent.selectedRange = NSRange(location: location, length: length)
                } else {
                    parent.selectedRange = nil
                }
            } else {
                parent.selectedRange = nil
            }
        }
    }
}

@preconcurrency
final class SafeGuardState: ObservableObject {
    @Published var redactedRanges: [NSRange] = []
    @Published var completedPrompts: Int = 0
    @Published var score: Int = 0
    @Published var completedRedactions: Set<Int> = []
    @Published var isCurrentPromptCompleted: Bool = false
    @Published var isTransitioning: Bool = false
    
    var prompts: [(text: String, sensitive: [NSRange])] = [
        (
            "Hi, my name is John Smith and I live at 123 Main Street. You can reach me at john.smith@email.com.",
            [
                NSRange(location: 14, length: 10),  
                NSRange(location: 34, length: 15),  
                NSRange(location: 65, length: 19)   
            ]
        ),
        (
            "My social security number is 123-45-6789 and my phone number is (555) 987-6543.",
            [
                NSRange(location: 25, length: 11),  
                NSRange(location: 56, length: 14)   
            ]
        ),
        (
            "Please charge my credit card 4111-1111-1111-1111 which expires on 12/25.",
            [
                NSRange(location: 27, length: 19),  
                NSRange(location: 61, length: 5)    
            ]
        ),
        (
            "The patient Sarah Johnson was born on 01/15/1990 and has medical record #MR987654.",
            [
                NSRange(location: 12, length: 13),  
                NSRange(location: 34, length: 10),  
                NSRange(location: 63, length: 9)    
            ]
        )
    ]
    
    func checkRedactions() -> Int {
        let currentSensitive = prompts[completedPrompts].sensitive
        var coveredCount = 0
        
        
        for sensitiveRange in currentSensitive {
            for redactedRange in redactedRanges {
                
                let sensitiveEnd = sensitiveRange.location + sensitiveRange.length
                let redactedEnd = redactedRange.location + redactedRange.length
                
                if !(redactedEnd <= sensitiveRange.location || redactedRange.location >= sensitiveEnd) {
                    
                    coveredCount += 1
                    break 
                }
            }
        }
        
        let percentage = (coveredCount * 100) / currentSensitive.count
        print("Covered \(coveredCount) out of \(currentSensitive.count) sensitive items") 
        score = percentage
        return percentage
    }
    
    func nextPrompt() {
        completedPrompts += 1
        redactedRanges = []
        isCurrentPromptCompleted = false
        isTransitioning = false
        score = 0
    }
}

#Preview {
    SafeGuardGame(gameState: GameState()) {
        
    }
    .padding()
}