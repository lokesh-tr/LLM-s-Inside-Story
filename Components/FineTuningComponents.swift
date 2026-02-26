import SwiftUI

struct ParameterSlider: View {
    let name: String
    @Binding var value: Double
    let onChange: (Double) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
            
            HStack {
                Slider(
                    value: $value,
                    in: 0...1,
                    onEditingChanged: { editing in
                        if !editing {
                            onChange(value)
                        }
                    }
                ) {
                    Text("")
                }
                .accentColor(.blue)
                
                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

struct OutputComparisonView: View {
    let currentOutputs: [String]
    let expectedOutputs: [String]
    let matchScore: Double
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Output Comparison")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack(spacing: 15) {
                Text("Current")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                
                Text("Expected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            ForEach(currentOutputs.indices, id: \.self) { index in
                HStack(spacing: 15) {
                    
                    Text(currentOutputs[index])
                        .multilineTextAlignment(.leading)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.blue)
                    
                    
                    Text(expectedOutputs[index])
                        .multilineTextAlignment(.leading)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
            .padding(.horizontal)
    }
}

struct ModelThoughtBubble: View {
    let thought: String
    
    var body: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundColor(.purple)
            
            Text(thought)
                .font(.body)
                .italic()
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.purple.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ProgressIndicator: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 8)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Rectangle()
                    .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 8)
                    .foregroundColor(color)
                    .animation(.spring(), value: progress)
            }
            .cornerRadius(4)
        }
    }
} 
