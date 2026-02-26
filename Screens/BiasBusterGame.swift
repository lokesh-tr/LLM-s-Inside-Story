import SwiftUI

@preconcurrency
final class BiasBusterState: ObservableObject {
    @Published var biasLevel: Double = 1.0  
    @Published var connectedSources: [DataSource] = []
    @Published var availableSources: [DataSource] = []
    
    init() {
        
        connectedSources = [
            DataSource(name: "Single Perspective News", type: .biased, icon: "newspaper.fill"),
            DataSource(name: "Echo Chamber", type: .biased, icon: "bubble.left.fill"),
            DataSource(name: "Limited Dataset", type: .biased, icon: "doc.fill")
        ]
        
        
        availableSources = [
            DataSource(name: "Diverse Perspectives", type: .balanced, icon: "person.3.fill"),
            DataSource(name: "Global Research", type: .balanced, icon: "globe"),
            DataSource(name: "Fact-Checked Data", type: .balanced, icon: "checkmark.shield.fill"),
            DataSource(name: "Cultural Studies", type: .balanced, icon: "books.vertical.fill"),
            DataSource(name: "Scientific Papers", type: .balanced, icon: "doc.text.fill")
        ]
        
        updateBiasLevel()
    }
    
    func connectSource(_ source: DataSource) {
        if let index = availableSources.firstIndex(of: source) {
            availableSources.remove(at: index)
            connectedSources.append(source)
            updateBiasLevel()
        }
    }
    
    func disconnectSource(_ source: DataSource) {
        if let index = connectedSources.firstIndex(of: source) {
            connectedSources.remove(at: index)
            availableSources.append(source)
            updateBiasLevel()
        }
    }
    
    private func updateBiasLevel() {
        let biasedCount = Double(connectedSources.filter { $0.type == .biased }.count)
        let balancedCount = Double(connectedSources.filter { $0.type == .balanced }.count)
        let total = biasedCount + balancedCount
        
        if total == 0 {
            biasLevel = 0
        } else {
            biasLevel = (biasedCount - balancedCount) / total
        }
    }
}

@preconcurrency
struct BiasBusterGame: View {
    @ObservedObject var gameState: GameState
    @StateObject private var state = BiasBusterState()
    @State private var showingSuccessAlert = false
    @State private var draggedSource: DataSource?
    let dismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                
                VStack(spacing: 8) {
                    Text("Model Bias Level")
                        .font(.headline)
                    
                    ZStack(alignment: .center) {
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                        
                        
                        GeometryReader { proxy in
                            let width = proxy.size.width
                            let midPoint = width / 2
                            let biasPoint = midPoint + (width / 2) * state.biasLevel
                            
                            
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 2, height: 20)
                                .position(x: midPoint, y: 10)
                            
                            
                            Circle()
                                .fill(biasColor)
                                .frame(width: 16, height: 16)
                                .position(x: biasPoint, y: 10)
                        }
                        
                        
                        HStack {
                            Text("Biased")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Balanced")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Biased")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 8)
                    }
                    
                    Text(String(format: "Bias: %.1f%%", abs(state.biasLevel * 100)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                
                ZStack {
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("LLM")
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                    
                    
                    ForEach(state.connectedSources) { source in
                        let angle = 2 * .pi * Double(state.connectedSources.firstIndex(of: source)!) / Double(state.connectedSources.count)
                        let radius: CGFloat = 120
                        let x = cos(angle) * radius
                        let y = sin(angle) * radius
                        
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        .stroke(source.type == .biased ? Color.red.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 2)
                        
                        DataSourceBubble(source: source)
                            .offset(x: x, y: y)
                            .onTapGesture {
                                withAnimation {
                                    state.disconnectSource(source)
                                }
                            }
                    }
                }
                .frame(height: 300)
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(state.availableSources) { source in
                            DataSourceBubble(source: source)
                                .onTapGesture {
                                    withAnimation {
                                        state.connectSource(source)
                                        checkCompletion()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 100)
                
                
                Text("Connect diverse knowledge sources to balance the model's perspective")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .alert("Bias Eliminated!", isPresented: $showingSuccessAlert) {
                Button("Continue") {
                    dismiss()
                }
            } message: {
                Text("You've successfully balanced the model's knowledge sources, making it more inclusive and fair!\n\nPoints awarded: 1000")
            }
        }
    }
    
    private var biasColor: Color {
        if state.biasLevel == 0 {
            return .green
        } else if abs(state.biasLevel) < 0.3 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private func checkCompletion() {
        if abs(state.biasLevel) < 0.1 {
            gameState.updateModuleScore(points: 1000, forModule: 8)
            gameState.completeMiniGame(4)
            showingSuccessAlert = true
        }
    }
}

@preconcurrency
struct DataSourceBubble: View {
    let source: DataSource
    
    var body: some View {
        VStack {
            Image(systemName: source.icon)
                .font(.title2)
                .foregroundColor(source.type == .biased ? .red : .green)
            Text(source.name)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .shadow(radius: 2)
        )
    }
}

@preconcurrency
struct DataSource: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let type: DataSourceType
    let icon: String
    
    enum DataSourceType {
        case biased
        case balanced
    }
}

#Preview {
    BiasBusterGame(gameState: GameState()) {
        
    }
    .padding()
} 