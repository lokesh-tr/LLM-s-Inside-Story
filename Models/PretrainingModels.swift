import Foundation
import SwiftUI

struct KnowledgeSource: Identifiable {
    let id = UUID()
    let type: KnowledgeType
    let knowledgeValue: Double
    var isConnected: Bool = false
    let position: CGPoint
    var isDragging: Bool = false
}

enum KnowledgeType: String, CaseIterable {
    case wikipedia = "Wikipedia"
    case books = "Non-Fiction Books"
    case scientific = "Scientific Papers"
    case web = "Web Content"
    case news = "News Articles"
    case blogs = "Tech Blogs"
    case code = "Code Repositories"
    case academic = "Academic Journals"
    case documentation = "Technical Docs"
    case forums = "Online Forums"
    
    var icon: String {
        switch self {
        case .wikipedia: return "book.closed"
        case .books: return "books.vertical"
        case .scientific: return "doc.text.magnifyingglass"
        case .web: return "globe"
        case .news: return "newspaper"
        case .blogs: return "text.quote"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .academic: return "graduationcap"
        case .documentation: return "doc.text"
        case .forums: return "bubble.left.and.bubble.right"
        }
    }
}

@MainActor
class PretrainingState: ObservableObject {
    @Published var knowledgeSources: [KnowledgeSource] = []
    @Published var modelKnowledgeScore: Double = 10.0
    @Published var modelSize: CGFloat = 100.0
    @Published var currentLevel: Int = 1
    @Published var maxLevel: Int = 3
    @Published var zoomScale: CGFloat = 1.0
    @Published var shouldShowMoreSources: Bool = false
    @Published var draggedSourceId: UUID?
    @Published var dragPosition: CGPoint?
    @Published var screenOpacity: Double = 1.0
    @Published var showingThought: Bool = false
    @Published var currentThought: String?
    
    private let sourceSize: CGFloat = 80
    private let minRadius: CGFloat = 120.0
    private let baseSourceCount = 2
    private let modelSizeThreshold: CGFloat = 140.0
    private var usedTypes: Set<KnowledgeType> = []
    
    
    private let baseScore: Double = 10.0 
    private let maxScore: Double = 100.0
    private let totalSources: Int = 12 
    private let scorePerSource: Double = 7.5 
    
    private func generateSourcePositions(forLevel level: Int, count: Int) -> [CGPoint] {
        let minR = minRadius * CGFloat(level)
        let maxR = minRadius * CGFloat(level) * 1.05
        let angleStep = (2.0 * .pi) / Double(count)
        
        return (0..<count).map { i in
            let baseAngle = Double(i) * angleStep + (.pi / 4.0)
            let angle = baseAngle + Double.random(in: -0.05...0.05)
            let radius = CGFloat.random(in: minR...(minR + (maxR - minR) * 0.8))
            return CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
        }
    }
    
    private func getUnusedKnowledgeType() -> KnowledgeType {
        let availableTypes = Set(KnowledgeType.allCases).subtracting(usedTypes)
        if availableTypes.isEmpty {
            usedTypes.removeAll()
            return KnowledgeType.allCases.randomElement()!
        }
        let type = availableTypes.randomElement()!
        usedTypes.insert(type)
        return type
    }
    
    private func getThoughtForLevel(_ level: Int) -> String {
        switch level {
        case 1:
            return "I'm starting to learn! Keep connecting more knowledge sources to help me grow. 🌱"
        case 2:
            return "I'm getting smarter! My knowledge is expanding, but there's still more to learn. 📚"
        case 3:
            return "Almost there! Help me connect with the final set of knowledge sources. 🎯"
        default:
            return ""
        }
    }
    
    func startDragging(_ sourceId: UUID, at position: CGPoint) {
        draggedSourceId = sourceId
        dragPosition = position
    }
    
    func updateDragPosition(_ position: CGPoint) {
        dragPosition = position
    }
    
    func endDragging(at position: CGPoint, modelCenter: CGPoint) {
        guard let sourceId = draggedSourceId,
              let index = knowledgeSources.firstIndex(where: { $0.id == sourceId }),
              !knowledgeSources[index].isConnected else {
            draggedSourceId = nil
            dragPosition = nil
            return
        }
        
        let distance = sqrt(pow(position.x - modelCenter.x, 2) + pow(position.y - modelCenter.y, 2))
        if distance <= modelSize / 2 {
            connectSource(sourceId)
        }
        
        draggedSourceId = nil
        dragPosition = nil
    }
    
    func connectSource(_ sourceId: UUID) {
        if let index = knowledgeSources.firstIndex(where: { $0.id == sourceId }) {
            knowledgeSources[index].isConnected = true
            
            
            modelKnowledgeScore = min(maxScore, modelKnowledgeScore + scorePerSource)
            modelSize += 20.0
            
            
            let visibleSources = knowledgeSources.filter { source in
                let distance = sqrt(pow(source.position.x, 2) + pow(source.position.y, 2))
                return distance <= minRadius * CGFloat(currentLevel) * 1.05
            }
            
            if visibleSources.allSatisfy(\.isConnected) {
                shouldShowMoreSources = true
                
                if currentLevel < maxLevel {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        screenOpacity = 0.0
                        showingThought = true
                        currentThought = getThoughtForLevel(currentLevel + 1)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.advanceLevel()
                        withAnimation(.easeInOut(duration: 0.7)) {
                            self.screenOpacity = 1.0
                        }
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation {
                            self.showingThought = false
                        }
                    }
                }
            }
        }
    }
    
    func generateNewSources(for level: Int) {
        let sourcesCount = baseSourceCount * level
        let positions = generateSourcePositions(forLevel: level, count: sourcesCount)
        
        let newSources = positions.map { position in
            KnowledgeSource(
                type: getUnusedKnowledgeType(),
                knowledgeValue: Double.random(in: 5...15),
                position: position
            )
        }
        knowledgeSources.append(contentsOf: newSources)
    }
    
    func advanceLevel() {
        if currentLevel < maxLevel {
            currentLevel += 1
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                zoomScale *= 0.85
            }
            generateNewSources(for: currentLevel)
            shouldShowMoreSources = false
        }
    }
    
    func reset() {
        currentLevel = 1
        modelKnowledgeScore = 10.0
        modelSize = 100.0
        knowledgeSources.removeAll()
        zoomScale = 1.0
        shouldShowMoreSources = false
        draggedSourceId = nil
        dragPosition = nil
        screenOpacity = 1.0
        usedTypes.removeAll()
        
        
        if knowledgeSources.isEmpty {
            generateNewSources(for: currentLevel)
        }
    }
    
    
    private func calculateGameScore() -> Int {
        
        let totalSources = knowledgeSources.count
        let connectedSources = knowledgeSources.filter(\.isConnected).count
        
        
        return Int((Double(connectedSources) / Double(totalSources)) * 100.0)
    }
    
    func isReadyForTest() -> Bool {
        
        let visibleSources = knowledgeSources.filter { source in
            let distance = sqrt(pow(source.position.x, 2) + pow(source.position.y, 2))
            return distance <= minRadius * CGFloat(currentLevel) * 1.05
        }
        return visibleSources.allSatisfy(\.isConnected)
    }
    
    func getTestResults() -> (passed: Bool, score: Int) {
        let passed = modelKnowledgeScore >= 85.0
        let pointsToAdd = calculateGameScore()  
        return (passed, passed ? pointsToAdd : 0)
    }
} 
