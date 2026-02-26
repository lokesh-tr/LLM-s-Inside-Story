import SwiftUI

struct ClosingModule: View {
    @ObservedObject var gameState: GameState
    @State private var showConfetti = false
    
    var impactAreas: [(title: String, description: String, icon: String)] = [
        ("Accessibility", "You've helped make AI more accessible to everyone", "person.fill.questionmark"),
        ("Sustainability", "You've contributed to reducing AI's environmental impact", "leaf.fill"),
        ("Privacy", "You've protected user data and privacy", "lock.fill")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 30) {
                    Text("Congratulations!")
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    VStack {
                        Text("Final Score")
                            .font(.title2)
                        Text("\(gameState.totalScore)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Your Impact")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(impactAreas, id: \.title) { area in
                            ImpactAreaCard(area: area)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            Text("Thank You for Playing!")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("You've not only learned about LLMs but also made the world more inclusive, safe, sustainable, and accessible. Your time was spent making a difference!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(15)
                    
                    Text("made with ❤️ by Lokesh T. R.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Button(action: {
                        withAnimation {
                            gameState.moduleScores.removeAll()
                            gameState.completedModules.removeAll()
                            gameState.totalScore = 0
                            gameState.currentModule = 1
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Play Again")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
                .frame(maxWidth: min(800, geometry.size.width))
                .padding(.horizontal)
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
            .overlay(
                ZStack {
                    if showConfetti {
                        ConfettiView()
                    }
                }
            )
        }
        .onAppear {
            withAnimation(.spring()) {
                showConfetti = true
            }
        }
    }
}

struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50) { index in
                ConfettiPiece(
                    color: colors[index % colors.count],
                    size: CGSize(width: 10, height: 10),
                    position: CGPoint(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: -50...geometry.size.height)
                    )
                )
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGSize
    let position: CGPoint
    
    @State private var animation = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size.width, height: size.height)
            .position(x: position.x, y: position.y)
            .opacity(animation ? 0 : 1)
            .onAppear {
                withAnimation(
                    Animation
                        .easeOut(duration: 3)
                        .repeatCount(1, autoreverses: false)
                ) {
                    animation = true
                }
            }
    }
}

struct ImpactAreaCard: View {
    let area: (title: String, description: String, icon: String)
    
    var gradient: LinearGradient {
        switch area.title {
        case "Accessibility":
            return LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Sustainability":
            return LinearGradient(colors: [.green.opacity(0.2), .mint.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Privacy":
            return LinearGradient(colors: [.indigo.opacity(0.2), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Inclusivity":
            return LinearGradient(colors: [.orange.opacity(0.2), .pink.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    var iconColor: Color {
        switch area.title {
        case "Accessibility": return .purple
        case "Sustainability": return .green
        case "Privacy": return .indigo
        case "Inclusivity": return .orange
        default: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            
            Circle()
                .fill(gradient)
                .overlay {
                    Image(systemName: area.icon)
                        .font(.title)
                        .foregroundColor(iconColor)
                }
                .frame(width: 60, height: 60)
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text(area.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(iconColor)
                
                Text(area.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}



#Preview("Closing Module - High Score") {
    ClosingModule(gameState: {
        let state = GameState()
        state.totalScore = 450
        return state
    }())
}

#Preview("Closing Module - Low Score") {
    ClosingModule(gameState: {
        let state = GameState()
        state.totalScore = 150
        return state
    }())
}

#Preview("Impact Area Card") {
    VStack(spacing: 20) {
        ImpactAreaCard(area: ("Sustainability", "You've contributed to reducing AI's environmental impact", "leaf.fill"))
        ImpactAreaCard(area: ("Privacy", "You've protected user data and privacy", "lock.fill"))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Confetti Animation") {
    ConfettiView()
        .frame(width: 300, height: 300)
        .background(Color.black.opacity(0.1))
}

#Preview("Final Score Display") {
    VStack {
        Text("Final Score")
            .font(.title2)
        Text("450")
            .font(.system(size: 60, weight: .bold))
            .foregroundColor(.blue)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color.blue.opacity(0.1))
    .cornerRadius(15)
    .padding()
}
