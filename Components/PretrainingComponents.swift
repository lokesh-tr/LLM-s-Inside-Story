import SwiftUI

struct ModelView: View {
    let size: CGFloat
    let score: Double
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Circle()
                        .strokeBorder(.blue.opacity(0.3), lineWidth: 2)
                }
            
            VStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: size * 0.3))
                    .foregroundStyle(.blue)
                
                Text("LLM")
                    .font(.system(size: size * 0.15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

struct KnowledgeSourceView: View {
    let source: KnowledgeSource
    let isConnected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            
            ZStack {
                Circle()
                    .fill(isConnected ? Color.green : Color.blue)
                    .frame(width: 40, height: 40)
                    .opacity(isConnected ? 0.7 : 1.0)
                
                Circle()
                    .stroke(Color.white, lineWidth: 1.5)
                    .frame(width: 40, height: 40)
                
                Image(systemName: source.type.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            
            Text(source.type.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isConnected ? .green : .blue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 70)
        }
        .scaleEffect(source.isDragging ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: source.isDragging)
    }
}

struct KnowledgeConnectionLine: Shape {
    var start: CGPoint
    var end: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}

struct LevelIndicator: View {
    let currentLevel: Int
    let maxLevel: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...maxLevel, id: \.self) { level in
                Circle()
                    .fill(level <= currentLevel ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

#Preview("Model View") {
    ModelView(size: 150, score: 75.0)
        .padding()
        .background(Color(uiColor: .systemBackground))
}

#Preview("Knowledge Source") {
    VStack(spacing: 20) {
        KnowledgeSourceView(
            source: KnowledgeSource(
                type: .wikipedia,
                knowledgeValue: 10,
                position: .zero
            ),
            isConnected: false
        )
        
        KnowledgeSourceView(
            source: KnowledgeSource(
                type: .books,
                knowledgeValue: 15,
                isConnected: true, position: .zero
            ),
            isConnected: true
        )
    }
    .padding()
    .background(Color(uiColor: .systemBackground))
}

#Preview("Level Indicator") {
    LevelIndicator(currentLevel: 2, maxLevel: 3)
        .padding()
        .background(Color(uiColor: .systemBackground))
} 
