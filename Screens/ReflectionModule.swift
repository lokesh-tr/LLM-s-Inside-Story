import SwiftUI

struct ReflectionModule: View {
    @ObservedObject var gameState: GameState
    @State private var selectedModule: Int?
    @State private var showingModuleSelection = false
    @State private var showingCelebration = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                
                Color.clear
                    .frame(height: 60)
                
                HStack {
                    Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                    
                    VStack(spacing: 30) {
                        Text("Your LLM Journey")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 10)
                        
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                Text("Your Learning Path")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.bottom, 5)
                            
                            Text("You've mastered the core concepts of Large Language Models:")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(2...6, id: \.self) { module in
                                    ModuleProgressCard(
                                        moduleNumber: module,
                                        score: gameState.moduleScores[module] ?? 0,
                                        maxScore: GameState.moduleMaxScores[module] ?? 100
                                    )
                                    .onTapGesture {
                                        selectedModule = module
                                        showingModuleSelection = true
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                        
                        
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.title)
                                    .foregroundColor(.yellow)
                                Text("Your Achievements")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(spacing: 15) {
                                AchievementRow(
                                    title: "Total Score",
                                    value: "\(gameState.totalScore)",
                                    icon: "trophy.fill",
                                    color: .orange
                                )
                                
                                AchievementRow(
                                    title: "Modules Completed",
                                    value: "\(gameState.completedModules.count)/5",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                                
                                if let highestScore = gameState.moduleScores.values.max() {
                                    AchievementRow(
                                        title: "Highest Module Score",
                                        value: "\(highestScore)",
                                        icon: "rosette",
                                        color: .purple
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(15)
                        
                        
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                                Text("Ready for Impact")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Text("Now that you understand how LLMs work, it's time to use this knowledge to make a real difference in the world!")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                            
                            Button(action: {
                                withAnimation {
                                    showingCelebration = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        gameState.currentModule = 8
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("Save the World!")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .frame(maxWidth: 800)
                    .padding()
                    
                    Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                }
                .frame(minHeight: geometry.size.height)
                .padding(.bottom, 30)
            }
        }
        .overlay {
            if showingCelebration {
//                CelebrationView()
            }
        }
        .alert("Review Module?", isPresented: $showingModuleSelection) {
            Button("Yes") {
                if let module = selectedModule {
                    withAnimation {
                        showingModuleSelection = false
                        gameState.currentModule = module
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                showingModuleSelection = false
                selectedModule = nil
            }
        } message: {
            if let module = selectedModule {
                Text("Would you like to review Module \(module): \(ModuleProgressCard(moduleNumber: module, score: 0, maxScore: 0).moduleTitle)?")
            }
        }
    }
}

struct AchievementRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct CelebrationView: View {
    let colors: [Color] = [.blue, .green, .yellow, .purple, .orange]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for i in 0..<20 {
                    let position = CGPoint(
                        x: size.width * CGFloat.random(in: 0...1),
                        y: size.height * CGFloat.random(in: 0...1)
                    )
                    let color = colors[i % colors.count]
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: position.x, y: position.y, width: 10, height: 10)),
                        with: .color(color)
                    )
                }
            }
            .opacity(0.7)
        }
    }
}

struct ModuleProgressCard: View {
    let moduleNumber: Int
    let score: Int
    let maxScore: Int
    
    var moduleTitle: String {
        switch moduleNumber {
        case 2: return "Tokenization"
        case 3: return "Attention"
        case 4: return "Pretraining"
        case 5: return "Fine Tuning"
        case 6: return "Next-Word Prediction"
        default: return "Unknown"
        }
    }
    
    var progress: Double {
        Double(score) / Double(maxScore)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Module \(moduleNumber): \(moduleTitle)")
                    .font(.headline)
                Spacer()
                Image(systemName: "arrow.right.circle")
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Score: \(score)/\(maxScore)")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.0f%%", progress * 100))
                    .fontWeight(.bold)
                    .foregroundColor(progress >= 0.8 ? .green : .orange)
            }
            
            ProgressIndicator(progress: progress, color: progress >= 0.8 ? .green : .orange)
                .frame(height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview("Reflection Module") {
    ReflectionModule(gameState: {
        let state = GameState()
        state.moduleScores = [
            2: 90,
            3: 85,
            4: 95,
            5: 80,
            6: 100
        ]
        state.completedModules = [2, 3, 4, 5, 6]
        return state
    }())
}

#Preview("Achievement Row") {
    AchievementRow(
        title: "Total Score",
        value: "450",
        icon: "trophy.fill",
        color: .orange
    )
    .padding()
}

#Preview("Module Progress Card") {
    ModuleProgressCard(
        moduleNumber: 5,
        score: 90,
        maxScore: 100
    )
    .padding()
}

#Preview("Celebration View") {
    CelebrationView()
        .frame(width: 300, height: 300)
        .background(Color.black.opacity(0.1))
} 
