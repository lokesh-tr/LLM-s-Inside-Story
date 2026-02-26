import SwiftUI
import UIKit

struct SelectableText: View {
    let text: String
    @Binding var selectedText: String
    
    var body: some View {
        SelectableTextRepresentable(text: text, selectedText: $selectedText)
            .frame(minHeight: 100)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

struct SelectableTextRepresentable: UIViewRepresentable {
    let text: String
    @Binding var selectedText: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.font = .preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.tintColor = .systemBlue
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedText: $selectedText)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var selectedText: String
        
        init(selectedText: Binding<String>) {
            self._selectedText = selectedText
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            if let range = textView.selectedTextRange {
                selectedText = textView.text(in: range) ?? ""
            }
        }
    }
}

struct ContextQuestionView: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Question:")
                .font(.headline)
            Text(question)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            Text("Expected Answer:")
                .font(.headline)
            Text(answer)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

struct FeedbackView: View {
    let isCorrect: Bool
    let selectedText: String
    let correctText: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(isCorrect ? .green : .red)
            
            if !isCorrect {
                Text("You selected: \(selectedText)")
                    .foregroundColor(.red)
                Text("Try highlighting: \(correctText)")
                    .foregroundColor(.green)
            } else {
                Text("Perfect! You found the relevant context!")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
} 