import SwiftUI

struct ScoreView: View {
    let score: Int
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("Score: \(score)")
                .font(.headline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
        }
    }
}

#Preview {
    ScoreView(score: 100)
} 