import SwiftUI

struct SkipModuleButton: View {
    @ObservedObject var gameState: GameState
    let currentModule: Int
    @State private var showingConfirmation = false
    
    var body: some View {
        Button(action: {
            showingConfirmation = true
        }) {
            HStack(spacing: 4) {
                Text("Skip")
                    .font(.subheadline)
                Image(systemName: "forward.fill")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
        .alert("Skip Module?", isPresented: $showingConfirmation) {
            Button("Skip", role: .destructive) {
                withAnimation {
                    gameState.currentModule = currentModule + 1
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to skip this module? You can always come back to it later from the reflection screen.")
        }
    }
}

#Preview {
    SkipModuleButton(gameState: GameState(), currentModule: 2)
} 