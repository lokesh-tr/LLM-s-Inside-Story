import SwiftUI

struct DotGridPattern: View {
    let spacing: CGFloat = 40
    let dotSize: CGFloat = 3
    
    var body: some View {
        Canvas { context, size in
            for x in stride(from: 0, through: size.width, by: spacing) {
                for y in stride(from: 0, through: size.height, by: spacing) {
                    let rect = CGRect(x: x - dotSize/2, y: y - dotSize/2,
                                    width: dotSize, height: dotSize)
                    context.fill(Path(ellipseIn: rect), with: .color(.gray.opacity(0.5)))
                }
            }
        }
        .frame(width: 1000, height: 1000)
    }
}

struct PretrainingExplanationView: View {
    @StateObject var state = PretrainingState()
    @State private var centerPoint: CGPoint = .zero
    @State private var showHint = false
    @State private var scrollViewProxy: ScrollViewProxy?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let onContinue: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                HStack {
                    Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                    
                    VStack(spacing: 24) {
                        
                        Color.clear
                            .frame(height: 60)
                        
                        Text("Pretraining Your Model")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Help the LLM grow by connecting it to knowledge sources!")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        
                        LevelIndicator(currentLevel: state.currentLevel, maxLevel: state.maxLevel)
                            .padding()
                        
                        
                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            ScrollViewReader { proxy in
                                ZStack {
                                    
                                    DotGridPattern()
                                        .allowsHitTesting(false)
                                    
                                    
                                    ForEach(state.knowledgeSources) { source in
                                        if source.isConnected {
                                            KnowledgeConnectionLine(
                                                start: CGPoint(
                                                    x: centerPoint.x + source.position.x * state.zoomScale,
                                                    y: centerPoint.y + source.position.y * state.zoomScale
                                                ),
                                                end: centerPoint
                                            )
                                            .stroke(Color.green.opacity(0.5), lineWidth: 2)
                                        }
                                    }
                                    
                                    
                                    if let dragPosition = state.dragPosition,
                                       let draggedId = state.draggedSourceId,
                                       let source = state.knowledgeSources.first(where: { $0.id == draggedId }) {
                                        KnowledgeConnectionLine(
                                            start: CGPoint(
                                                x: centerPoint.x + source.position.x * state.zoomScale,
                                                y: centerPoint.y + source.position.y * state.zoomScale
                                            ),
                                            end: dragPosition
                                        )
                                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                                    }
                                    
                                    
                                    ForEach(state.knowledgeSources) { source in
                                        KnowledgeSourceView(
                                            source: source,
                                            isConnected: source.isConnected
                                        )
                                        .position(
                                            x: centerPoint.x + source.position.x * state.zoomScale,
                                            y: centerPoint.y + source.position.y * state.zoomScale
                                        )
                                        .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { value in
                                                    if !source.isConnected {
                                                        state.startDragging(source.id, at: value.location)
                                                        state.updateDragPosition(value.location)
                                                    }
                                                }
                                                .onEnded { value in
                                                    state.endDragging(at: value.location, modelCenter: centerPoint)
                                                }
                                        )
                                    }
                                    
                                    
                                    ModelView(size: state.modelSize, score: state.modelKnowledgeScore)
                                        .position(centerPoint)
                                        .id("centerModel")
                                }
                                .frame(width: 1000, height: 1000)
                                .opacity(state.screenOpacity)
                                .onAppear {
                                    centerPoint = CGPoint(x: 500, y: 500)
                                    
                                    
                                    if state.knowledgeSources.isEmpty {
                                        state.generateNewSources(for: state.currentLevel)
                                    }
                                    
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            proxy.scrollTo("centerModel", anchor: .center)
                                        }
                                    }
                                    
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showHint = true
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: verticalSizeClass == .compact ? geometry.size.height * 0.5 : geometry.size.height * 0.4)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.gray, lineWidth: 1.5)
                                .padding()
                        )
                        
                        
                        Group {
                            if state.showingThought {
                                ThoughtBubbleView(
                                    showingExplanation: state.showingThought,
                                    explanation: state.currentThought,
                                    isPad: horizontalSizeClass == .regular
                                )
                            } else if showHint && !state.knowledgeSources.contains(where: \.isConnected) {
                                Text("Drag knowledge sources to the model to connect them!")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        
                        Button {
                            onContinue()
                        } label: {
                            Text("Continue →")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding()
                    }
                    .frame(maxWidth: 800)
                    .padding()
                    .frame(minHeight: geometry.size.height)
                    
                    Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                }
            }
        }
    }
}

#Preview {
    PretrainingExplanationView(onContinue: {})
}

#Preview("Level Progress") {
    let view = PretrainingExplanationView(onContinue: {})
    view.state.currentLevel = 2
    view.state.modelKnowledgeScore = 45.0
    view.state.modelSize = 140.0
    return view
} 
