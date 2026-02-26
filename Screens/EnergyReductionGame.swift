import SwiftUI

@preconcurrency
final class EnergyReductionState: ObservableObject {
    @Published var parameters: [String: Double] = [
        "Model Size": 0.8,
        "Layer Count": 0.7,
        "Attention Heads": 0.6,
        "Batch Processing": 0.5
    ]
    
    @Published var energyConsumption: Double = 0.8
    @Published var outputQuality: Double = 0.9
    @Published var carbonFootprint: Double = 0.8
    
    func updateParameters(_ parameter: String, value: Double) {
        parameters[parameter] = value
        updateMetrics()
    }
    
    private func updateMetrics() {
        
        let modelSizeImpact = (parameters["Model Size"] ?? 0) * 0.23
        let layerCountImpact = (parameters["Layer Count"] ?? 0) * 0.23
        let attentionHeadsImpact = (parameters["Attention Heads"] ?? 0) * 0.12
        let batchProcessingImpact = (parameters["Batch Processing"] ?? 0) * 0.12
        
        energyConsumption = 0.17 + modelSizeImpact + layerCountImpact + attentionHeadsImpact + batchProcessingImpact
        
        
        let modelSizeCarbonImpact = (parameters["Model Size"] ?? 0) * 0.25
        let batchProcessingCarbonImpact = (parameters["Batch Processing"] ?? 0) * 0.2
        let layerCountCarbonImpact = (parameters["Layer Count"] ?? 0) * 0.15
        let attentionHeadsCarbonImpact = (parameters["Attention Heads"] ?? 0) * 0.1
        
        carbonFootprint = 0.15 + modelSizeCarbonImpact + batchProcessingCarbonImpact + layerCountCarbonImpact + attentionHeadsCarbonImpact
        
        
        let baseQuality = 0.75
        let modelSizeQuality = (parameters["Model Size"] ?? 0) * 0.12
        let layerCountQuality = (parameters["Layer Count"] ?? 0) * 0.08
        let attentionHeadsQuality = (parameters["Attention Heads"] ?? 0) * 0.04
        let batchProcessingQuality = (parameters["Batch Processing"] ?? 0) * 0.04
        
        outputQuality = min(1.0, baseQuality + modelSizeQuality + layerCountQuality + attentionHeadsQuality + batchProcessingQuality)
    }
}

@preconcurrency
struct EnergyReductionGame: View {
    @ObservedObject var gameState: GameState
    @StateObject private var state = EnergyReductionState()
    @State private var showingSuccessAlert = false
    @State private var showingThought = true  
    @State private var currentThought = "Try reducing Model Size and Layer Count to around 40% first, as they have the biggest impact on energy usage."
    @State private var thoughtTimer: Timer?
    let dismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                        Text("Energy Consumption")
                            .font(.headline)
                    }
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.green, .yellow, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * state.energyConsumption, height: 20)
                        
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 2)
                            .frame(height: 24)
                            .offset(x: geometry.size.width * 0.4)
                    }
                    .cornerRadius(10)
                    
                    HStack {
                        Text(String(format: "%.1f%%", state.energyConsumption * 100))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("(Target: ≤ 40%)")
                            .font(.caption)
                            .foregroundStyle(state.energyConsumption <= 0.4 ? .green : .secondary)
                    }
                }
                .padding(.horizontal)
                
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                        Text("Carbon Footprint")
                            .font(.headline)
                    }
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.green, .yellow, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * state.carbonFootprint, height: 20)
                        
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 2)
                            .frame(height: 24)
                            .offset(x: geometry.size.width * 0.35)
                    }
                    .cornerRadius(10)
                    
                    HStack {
                        Text(String(format: "%.1f%%", state.carbonFootprint * 100))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("(Target: ≤ 35%)")
                            .font(.caption)
                            .foregroundStyle(state.carbonFootprint <= 0.35 ? .green : .secondary)
                    }
                }
                .padding(.horizontal)
                
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Output Quality")
                            .font(.headline)
                    }
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: geometry.size.width * state.outputQuality, height: 20)
                        
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 2)
                            .frame(height: 24)
                            .offset(x: geometry.size.width * 0.8)
                    }
                    .cornerRadius(10)
                    
                    HStack {
                        Text(String(format: "%.1f%%", state.outputQuality * 100))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("(Target: ≥ 80%)")
                            .font(.caption)
                            .foregroundStyle(state.outputQuality >= 0.8 ? .green : .secondary)
                    }
                }
                .padding(.horizontal)
                
                
                if showingThought {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.circle.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Optimization Hint")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(currentThought)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(radius: 2)
                    )
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .frame(maxWidth: .infinity)
                }
                
                
                VStack(spacing: 12) {
                    Text("Optimization Parameters")
                        .font(.headline)
                    
                    ForEach(Array(state.parameters.keys), id: \.self) { parameter in
                        EnergySlider(
                            name: parameter,
                            value: .init(
                                get: { state.parameters[parameter] ?? 0 },
                                set: { 
                                    state.parameters[parameter] = $0
                                    updateThought(for: parameter, value: $0)
                                }
                            ),
                            onChange: { 
                                state.updateParameters(parameter, value: $0)
                            }
                        )
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                
                if state.energyConsumption <= 0.4 && state.outputQuality >= 0.8 && state.carbonFootprint <= 0.35 {
                    Button {
                        gameState.updateModuleScore(points: 1000, forModule: 8)
                        gameState.completeMiniGame(2)
                        showingSuccessAlert = true
                    } label: {
                        Text("Optimize Model")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .animation(.easeInOut, value: showingThought)
            .alert("Excellent Work!", isPresented: $showingSuccessAlert) {
                Button("Continue") {
                    dismiss()
                }
            } message: {
                Text("You've successfully optimized the model to be more energy-efficient while maintaining high-quality outputs!\n\nPoints awarded: 1000")
            }
            .onDisappear {
                cleanup()
            }

            .padding(.bottom, 30)
        }
    }
    
    private func updateThought(for parameter: String, value: Double) {
        
        thoughtTimer?.invalidate()
        
        withAnimation {
            showingThought = true
            
            
            let isEnergyHigh = state.energyConsumption > 0.4
            let isQualityLow = state.outputQuality < 0.8
            let isCarbonHigh = state.carbonFootprint > 0.35
            
            switch parameter {
            case "Model Size":
                if value > 0.6 {
                    currentThought = "Model Size has the strongest impact on all metrics. Try reducing it to 40-50% to significantly lower both energy and carbon footprint."
                } else if value < 0.3 {
                    currentThought = "Warning: Model Size too low! This will severely impact quality. Keep it above 40% to maintain good performance."
                } else if isQualityLow {
                    currentThought = "Try increasing Model Size slightly to improve quality, but watch the energy and carbon impact."
                } else if isEnergyHigh || isCarbonHigh {
                    currentThought = "Consider reducing Model Size a bit more to meet energy and carbon targets."
                } else {
                    currentThought = "Good Model Size balance! Adjust other parameters to fine-tune the metrics."
                }
                
            case "Layer Count":
                if value > 0.6 {
                    currentThought = "High Layer Count increases both energy use and carbon footprint. Try reducing to 40-50%."
                } else if value < 0.3 {
                    currentThought = "Warning: Too few layers will hurt model quality. Aim for at least 40%."
                } else if isQualityLow {
                    currentThought = "Consider increasing Layer Count slightly to improve quality, but monitor energy usage."
                } else {
                    currentThought = "Layer Count looks good. Focus on Attention Heads and Batch Processing next."
                }
                
            case "Attention Heads":
                if value > 0.6 {
                    currentThought = "Too many Attention Heads. Try reducing to 40-50% to save energy while maintaining pattern recognition."
                } else if value < 0.3 {
                    currentThought = "Too few Attention Heads will limit model capabilities. Keep above 35%."
                } else if isQualityLow {
                    currentThought = "Current Attention Heads setting is good for efficiency. Check Model Size and Layer Count if quality is still low."
                } else {
                    currentThought = "Good Attention Heads balance. Adjust Batch Processing if needed."
                }
                
            case "Batch Processing":
                if value > 0.6 {
                    currentThought = "High Batch Processing significantly increases carbon footprint. Reduce to 40-50%."
                } else if value < 0.3 {
                    currentThought = "Batch Processing too low for efficient processing. Increase to at least 35%."
                } else if isCarbonHigh {
                    currentThought = "Consider reducing Batch Processing further to meet carbon target."
                } else {
                    currentThought = "Good balance! Check if all three targets are met: Energy ≤40%, Quality ≥80%, Carbon ≤35%"
                }
            default:
                if isEnergyHigh || isCarbonHigh {
                    currentThought = "Focus on reducing Model Size and Batch Processing first to meet environmental targets."
                } else if isQualityLow {
                    currentThought = "Quality needs improvement. Try fine-tuning Model Size and Layer Count."
                } else {
                    currentThought = "Keep adjusting parameters to find the optimal balance between performance and environmental impact."
                }
            }
            
            
            thoughtTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                Task { @MainActor in
                    withAnimation {
                        showingThought = false
                    }
                }
            }
        }
    }
    
    
    private func cleanup() {
        thoughtTimer?.invalidate()
        thoughtTimer = nil
    }
}

@preconcurrency
struct EnergySlider: View {
    let name: String
    @Binding var value: Double
    let onChange: (Double) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.0f%%", value * 100))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Slider(value: $value) { _ in
                onChange(value)
            }
        }
    }
}

#Preview {
    EnergyReductionGame(gameState: GameState()) {
        
    }
    .padding()
} 
