import SwiftUI

struct ThoughtBubbleView: View {
    let showingExplanation: Bool
    let explanation: String?
    let isPad: Bool
    
    var body: some View {
        VStack {
            if showingExplanation, let explanation {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(isPad ? .system(size: 40) : .title)
                        .foregroundStyle(.purple)
                        .frame(width: isPad ? 50 : 30)
                    
                    Text(explanation)
                        .font(isPad ? .title3 : .callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, isPad ? 32 : 16)
                .padding(.vertical, isPad ? 24 : 16)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .secondarySystemBackground))
                }
                .padding(.horizontal)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(minHeight: isPad ? 120 : 80)
        .animation(.spring(duration: 0.4), value: showingExplanation)
    }
}

#Preview {
    ThoughtBubbleView(
        showingExplanation: true,
        explanation: "This is a sample explanation that demonstrates how the thought bubble looks with some content! 🤔",
        isPad: true
    )
    .padding()
} 