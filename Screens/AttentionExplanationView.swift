import SwiftUI

struct AttentionExplanationView: View {
    @Binding var selectedHead: AttentionHead?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showingExplanation = false
    let onContinue: () -> Void
    
    private let exampleSentence = "The happy dog plays with its favorite toy"
    private let words: [String]
    private let connections: [AttentionConnection]
    
    
    private let headExplanations: [AttentionHead: String] = [
        .nouns: "I use this head to understand which words are objects or things. For example, 'dog' and 'toy' are nouns, and I can see how they relate to other words in the sentence! 🐕",
        .verbs: "This head helps me understand actions in the sentence. I can see that 'dog' is connected to 'plays' because the dog is doing the action! 🎮",
        .emotions: "With this head, I can detect emotional words and their connections. See how 'happy' relates to 'dog' and 'favorite' relates to 'toy'! 😊",
        .relationships: "This head helps me understand how different things are connected. I can see that the 'dog' has a relationship with the 'toy' because it's playing with it! 🔗"
    ]
    
    init(selectedHead: Binding<AttentionHead?>, onContinue: @escaping () -> Void) {
        self._selectedHead = selectedHead
        self.onContinue = onContinue
        self.words = exampleSentence.split(separator: " ").map(String.init)
        self.connections = [
            AttentionConnection(from: "happy", to: "dog", head: .emotions),
            AttentionConnection(from: "dog", to: "plays", head: .verbs),
            AttentionConnection(from: "dog", to: "toy", head: .relationships),
            AttentionConnection(from: "favorite", to: "toy", head: .emotions),
            AttentionConnection(from: "dog", to: "its", head: .nouns),
            AttentionConnection(from: "toy", to: "favorite", head: .nouns)
        ]
    }
    
    private var isHorizontalLayout: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isPad = horizontalSizeClass == .regular
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            
                            Text("Understanding Attention")
                                .font(isPad ? .largeTitle : .title)
                                .bold()
                                .padding(.top, 32)
                            
                            Text("Attention helps the model understand relationships between words in a sentence. Each colored line represents a different type of connection.")
                                .font(isPad ? .title3 : .body)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            
                            ThoughtBubbleView(
                                showingExplanation: showingExplanation,
                                explanation: selectedHead.flatMap { headExplanations[$0] },
                                isPad: isPad
                            )
                            
                            
                            ZStack {
                                
                                if false {
                                    HStack(spacing: isPad ? 16 : 12) {
                                        ForEach(words, id: \.self) { word in
                                            WordView(
                                                word: word,
                                                backgroundColor: Color(.systemGray6),
                                                isPad: isPad
                                            )
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 40)
                                    .padding(.horizontal, isPad ? 40 : 20)
                                } else {
                                    VStack(spacing: isPad ? 12 : 8) {
                                        ForEach(words, id: \.self) { word in
                                            WordView(
                                                word: word,
                                                backgroundColor: Color(.systemGray6),
                                                isPad: isPad
                                            )
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        }
                                    }
                                    .padding(.horizontal, isPad ? 40 : 20)
                                }
                                
                                
                                ForEach(connections, id: \.id) { connection in
                                    if selectedHead == nil || selectedHead == connection.head {
                                        WordConnectionLine(
                                            from: connection.from,
                                            to: connection.to,
                                            color: connection.head.color.opacity(0.8),
                                            words: words,
                                            spacing: isPad ? (isHorizontalLayout ? 16 : 12) : (isHorizontalLayout ? 12 : 8),
                                            wordHeight: isPad ? 52 : 44,
                                            horizontalPadding: isPad ? 20 : 16,
                                            verticalPadding: isPad ? 16 : 12,
                                            isHorizontalLayout: false
                                        )
                                    }
                                }
                            }
                            .frame(height: false ? (isPad ? 160 : 120) : CGFloat(words.count) * (isPad ? 64 : 52))
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Heads of Attention")
                                    .font(isPad ? .title3 : .headline)
                                    .foregroundStyle(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: isPad ? 16 : 12) {
                                        ForEach(AttentionHead.allCases, id: \.self) { head in
                                            AttentionHeadButton(
                                                head: head,
                                                isSelected: selectedHead == head,
                                                action: {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        if selectedHead == head {
                                                            selectedHead = nil
                                                            showingExplanation = false
                                                        } else {
                                                            selectedHead = head
                                                            showingExplanation = true
                                                            
                                                            
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                                                withAnimation {
                                                                    showingExplanation = false
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            
                            
                            Button(action: onContinue) {
                                Label("Continue to Game", systemImage: "play.fill")
                                    .font(isPad ? .title3 : .headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, isPad ? 16 : 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: isPad ? 16 : 12)
                                            .fill(Color.accentColor)
                                    )
                            }
                        }
                        .padding()
                        
                        Spacer(minLength: geometry.size.width > 800 ? (geometry.size.width - 800) / 2 : 0)
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct WordConnectionLine: View {
    let from: String
    let to: String
    let color: Color
    let words: [String]
    let spacing: CGFloat
    let wordHeight: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let isHorizontalLayout: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let fromIndex = words.firstIndex(of: from) ?? 0
            let toIndex = words.firstIndex(of: to) ?? 0
            
            if isHorizontalLayout {
                
                let wordWidths = words.map { $0.width(font: .title3) }
                let totalWordsWidth = wordWidths.reduce(0, +)
                let totalSpacing = spacing * CGFloat(words.count - 1)
                let startOffset = (geometry.size.width - (totalWordsWidth + totalSpacing)) / 2
                
                
                let xPositions: [CGFloat] = {
                    var positions: [CGFloat] = []
                    var currentX = startOffset
                    
                    wordWidths.forEach { width in
                        currentX += width / 2
                        positions.append(currentX)
                        currentX += width / 2 + spacing
                    }
                    
                    return positions
                }()
                
                let fromX = xPositions[fromIndex]
                let toX = xPositions[toIndex]
                let startY = 0.0
                
                Path { path in
                    let distance = abs(toX - fromX)
                    let curveOffset = -min(distance * 0.3, 30.0)
                    let controlY = startY + curveOffset
                    
                    path.move(to: CGPoint(x: fromX, y: startY))
                    path.addCurve(
                        to: CGPoint(x: toX, y: startY),
                        control1: CGPoint(x: fromX, y: controlY),
                        control2: CGPoint(x: toX, y: controlY)
                    )
                }
                .stroke(color, lineWidth: 2)
                
                
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .position(x: fromX, y: startY)
                
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .position(x: toX, y: startY)
                
            } else {
                
                let fromY = (wordHeight + spacing) * CGFloat(fromIndex) + wordHeight / 2
                let toY = (wordHeight + spacing) * CGFloat(toIndex) + wordHeight / 2
                
                
                let fromWidth = from.width(font: .title3)
                let toWidth = to.width(font: .title3)
                
                
                let containerWidth = geometry.size.width - (horizontalPadding * 2)
                let wordContainerWidth = max(fromWidth, toWidth) + (horizontalPadding * 2)
                
                
                let startX = (containerWidth - wordContainerWidth) / 2 + wordContainerWidth + horizontalPadding
                
                Path { path in
                    let distance = abs(toY - fromY)
                    let curveOffset = min(distance * 0.3, 30.0)
                    let endX = startX + curveOffset * 2
                    
                    path.move(to: CGPoint(x: startX, y: fromY))
                    path.addCurve(
                        to: CGPoint(x: startX, y: toY),
                        control1: CGPoint(x: endX, y: fromY),
                        control2: CGPoint(x: endX, y: toY)
                    )
                }
                .stroke(color, lineWidth: 2)
                
                
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .position(x: startX, y: fromY)
                
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .position(x: startX, y: toY)
            }
        }
    }
}

@preconcurrency
struct AttentionConnection: Sendable {
    let id = UUID()
    let from: String
    let to: String
    let head: AttentionHead
}

struct AttentionHeadButton: View {
    let head: AttentionHead
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Button(action: action) {
            Text(head.rawValue)
                .font(horizontalSizeClass == .regular ? .headline : .subheadline)
                .foregroundColor(isSelected ? .white : head.color)
                .padding(.horizontal, horizontalSizeClass == .regular ? 16 : 12)
                .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
                .background(
                    RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 12 : 8)
                        .fill(isSelected ? head.color : head.color.opacity(0.15))
                )
        }
    }
}

extension String {
    func width(font: Font) -> CGFloat {
        self.size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: font.textStyle)]).width
    }
}

extension Font {
    var textStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        default: return .body
        }
    }
}




















































