import SwiftUI

struct WordView: View {
    let word: String
    let backgroundColor: Color
    let isPad: Bool
    
    var body: some View {
        Text(word)
            .font(isPad ? .title3 : .body)
            .padding(.horizontal, isPad ? 20 : 16)
            .padding(.vertical, isPad ? 16 : 12)
            .background {
                RoundedRectangle(cornerRadius: isPad ? 16 : 12)
                    .fill(backgroundColor)
            }
            .fixedSize()
    }
}

#Preview {
    HStack {
        WordView(word: "Sample", backgroundColor: .blue.opacity(0.15), isPad: true)
        WordView(word: "Word", backgroundColor: .purple.opacity(0.15), isPad: true)
    }
    .padding()
} 