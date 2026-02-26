import SwiftUI

struct AudioRefinementGame: View {
    @ObservedObject var gameState: GameState
    @StateObject private var state = AudioRefinementState()
    @State private var showingSuccessAlert = false
    @State private var dragStart: CGPoint?
    @State private var currentBox: CGRect?
    @State private var selectedCells: Set<GridPoint> = []
    @State private var currentSelection: Set<GridPoint> = []
    let dismiss: () -> Void
    
    init(gameState: GameState, dismiss: @escaping () -> Void) {
        self.gameState = gameState
        self.dismiss = dismiss
    }
    
    var body: some View {
        VStack(spacing: 20) {
            instructionsSection
            gridSection
            actionButtons
        }
        .padding()
        .alert("Audio Data Refined!", isPresented: $showingSuccessAlert) {
            Button("Continue") {
                gameState.updateModuleScore(points: 1000, forModule: 8)
                gameState.completeMiniGame(1)
                dismiss()
            }
        } message: {
            Text("You've successfully cleaned the audio signals! The LLM can now process voice commands more accurately.\n\nPoints awarded: 1000")
        }
    }
    
    private var instructionsSection: some View {
        VStack(spacing: 8) {
            Text("Help Mark S. clean the audio signals")
                .font(.headline)
            Text("Use arrow buttons to move the grid view and drag to box anomalies")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Label("\(state.foundAnomalies.count) of 5 anomalies found", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(state.foundAnomalies.count > 0 ? .green : .secondary)
                
                Spacer()
                
                if !state.foundAnomalies.isEmpty {
                    Button("Reset", action: state.reset)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
    }
    
    private var gridSection: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cellSize = (size - CGFloat(state.viewportSize + 1)) / CGFloat(state.viewportSize)
            
            VStack(spacing: 20) {
                
                ZStack {
                    VStack(spacing: 1) {
                        ForEach(0..<state.viewportSize, id: \.self) { row in
                            HStack(spacing: 1) {
                                ForEach(0..<state.viewportSize, id: \.self) { col in
                                    let actualRow = row + state.viewportOffset.row
                                    let actualCol = col + state.viewportOffset.col
                                    let point = GridPoint(row: actualRow, col: actualCol)
                                    let content = state.grid[actualRow][actualCol]
                                    let background = cellBackground(for: point)
                                    let border = cellBorder(for: point)
                                    
                                    AnimatedCell(
                                        content: content,
                                        cellSize: cellSize,
                                        background: background,
                                        border: AnyView(border),
                                        animation: state.getAnimation(for: point)
                                    )
                                }
                            }
                        }
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if dragStart == nil {
                                dragStart = value.startLocation
                                currentSelection.removeAll()
                            }
                            let minX = min(dragStart?.x ?? 0, value.location.x)
                            let minY = min(dragStart?.y ?? 0, value.location.y)
                            let width = abs((dragStart?.x ?? 0) - value.location.x)
                            let height = abs((dragStart?.y ?? 0) - value.location.y)
                            currentBox = CGRect(x: minX, y: minY, width: width, height: height)
                            
                            
                            let startRow = Int((minY / size) * CGFloat(state.viewportSize))
                            let startCol = Int((minX / size) * CGFloat(state.viewportSize))
                            let endRow = Int(((minY + height) / size) * CGFloat(state.viewportSize))
                            let endCol = Int(((minX + width) / size) * CGFloat(state.viewportSize))
                            
                            currentSelection = Set(
                                (max(0, startRow)...min(state.viewportSize - 1, endRow)).flatMap { row in
                                    (max(0, startCol)...min(state.viewportSize - 1, endCol)).map { col in
                                        GridPoint(
                                            row: row + state.viewportOffset.row,
                                            col: col + state.viewportOffset.col
                                        )
                                    }
                                }
                            )
                        }
                        .onEnded { _ in
                            selectedCells = currentSelection
                            dragStart = nil
                            currentBox = nil
                            currentSelection.removeAll()
                        }
                )
                
                
                HStack(spacing: 0) {
                    
                    HStack {
                        Spacer()
                        
                        
                        VStack(spacing: 0) {
                            
                            Button {
                                state.moveViewport(dx: 0, dy: -1)
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(state.currentSteps.row > -state.maxSteps ? .blue : .gray)
                            }
                            .disabled(state.currentSteps.row <= -state.maxSteps)
                            .frame(width: 44, height: 44)
                            
                            
                            HStack(spacing: 44) {
                                Button {
                                    state.moveViewport(dx: -1, dy: 0)
                                } label: {
                                    Image(systemName: "arrow.left.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundStyle(state.currentSteps.col > -state.maxSteps ? .blue : .gray)
                                }
                                .disabled(state.currentSteps.col <= -state.maxSteps)
                                .frame(width: 44, height: 44)
                                
                                Button {
                                    state.moveViewport(dx: 1, dy: 0)
                                } label: {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundStyle(state.currentSteps.col < state.maxSteps ? .blue : .gray)
                                }
                                .disabled(state.currentSteps.col >= state.maxSteps)
                                .frame(width: 44, height: 44)
                            }
                            
                            
                            Button {
                                state.moveViewport(dx: 0, dy: 1)
                            } label: {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(state.currentSteps.row < state.maxSteps ? .blue : .gray)
                            }
                            .disabled(state.currentSteps.row >= state.maxSteps)
                            .frame(width: 44, height: 44)
                        }
                        .frame(width: 132)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                    Button {
                        state.checkAndRefineSelection(selectedCells)
                        selectedCells.removeAll()
                        if state.foundAnomalies.count == 5 {
                            gameState.completeMiniGame(1)
                            showingSuccessAlert = true
                        }
                    } label: {
                        Label("Refine Audio Data", systemImage: "wand.and.stars")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 132)
                            .background(
                                !selectedCells.isEmpty || state.foundAnomalies.count == 5 ?
                                    Color.purple : Color.purple.opacity(0.5)
                            )
                            .cornerRadius(10)
                    }
                    .disabled(selectedCells.isEmpty && state.foundAnomalies.count < 5)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
    
    private func cellBackground(for point: GridPoint) -> Color {
        if currentSelection.contains(point) || selectedCells.contains(point) {
            return .blue.opacity(0.2)
        } else if state.isSymbol(at: point) {
            return .purple.opacity(0.1)
        }
        return .clear
    }
    
    private func cellBorder(for point: GridPoint) -> some View {
        Group {
            if state.foundAnomalies.contains(where: { $0.contains(point) }) {
                Rectangle().strokeBorder(Color.purple, lineWidth: 2)
            } else if currentSelection.contains(point) || selectedCells.contains(point) {
                Rectangle().strokeBorder(Color.blue, lineWidth: 1)
            } else {
                Rectangle().strokeBorder(Color.clear, lineWidth: 0)
            }
        }
    }
    
    private var actionButtons: some View {
        EmptyView()
    }
}

class AudioRefinementState: ObservableObject {
    let gridSize = 10 
    let viewportSize = 8 
    let maxSteps = 2 
    @Published var grid: [[String]] = []
    @Published var foundAnomalies: Set<Set<GridPoint>> = []
    @Published var viewportOffset = GridPoint(row: 0, col: 0) 
    @Published var currentSteps = GridPoint(row: 0, col: 0) 
    private var anomalies: Set<Set<GridPoint>> = []
    private let symbols = ["!", "@", "#", "$", "%", "&", "*"]
    
    
    private var cellAnimations: [GridPoint: CellAnimation] = [:]
    
    struct CellAnimation {
        let radius: CGFloat
        let speed: Double
        let phase: Double
        let clockwise: Bool
        let startTime: TimeInterval
    }
    
    init() {
        reset()
    }
    
    func reset() {
        grid = Array(repeating: Array(repeating: "", count: gridSize), count: gridSize)
        cellAnimations.removeAll()
        
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let point = GridPoint(row: row, col: col)
                grid[row][col] = String(Int.random(in: 0...9))
                cellAnimations[point] = CellAnimation(
                    radius: CGFloat.random(in: 1.5...3.0),
                    speed: Double.random(in: 1.0...2.5),
                    phase: Double.random(in: 0...2 * .pi),
                    clockwise: Bool.random(),
                    startTime: Date.timeIntervalSinceReferenceDate
                )
            }
        }
        
        foundAnomalies.removeAll()
        anomalies.removeAll()
        viewportOffset = GridPoint(row: 0, col: 0)
        currentSteps = GridPoint(row: 0, col: 0)
        
        for _ in 0..<5 {
            createAnomaly()
        }
    }
    
    func getAnimation(for point: GridPoint) -> CellAnimation {
        if let animation = cellAnimations[point] {
            return animation
        }
        
        let animation = CellAnimation(
            radius: CGFloat.random(in: 1.5...3.0),
            speed: Double.random(in: 1.0...2.5),
            phase: Double.random(in: 0...2 * .pi),
            clockwise: Bool.random(),
            startTime: Date.timeIntervalSinceReferenceDate
        )
        cellAnimations[point] = animation
        return animation
    }
    
    func removeSelectedAnomalies() {
        for anomaly in foundAnomalies {
            for point in anomaly {
                grid[point.row][point.col] = String(Int.random(in: 0...9))
            }
        }
        foundAnomalies.removeAll()
    }
    
    private func createAnomaly() {
        let size = 2 
        var points = Set<GridPoint>()
        
        var row = Int.random(in: 0...(gridSize - size))
        var col = Int.random(in: 0...(gridSize - size))
        
        while hasOverlap(at: row, col: col, size: size) {
            row = Int.random(in: 0...(gridSize - size))
            col = Int.random(in: 0...(gridSize - size))
        }
        
        
        for r in row..<(row + size) {
            for c in col..<(col + size) {
                grid[r][c] = symbols.randomElement()!
                points.insert(GridPoint(row: r, col: c))
            }
        }
        
        anomalies.insert(points)
    }
    
    private func hasOverlap(at row: Int, col: Int, size: Int) -> Bool {
        for r in (row - 1)...(row + size) {
            for c in (col - 1)...(col + size) {
                if r >= 0 && r < gridSize && c >= 0 && c < gridSize {
                    let point = GridPoint(row: r, col: c)
                    if anomalies.contains(where: { $0.contains(point) }) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isSymbol(at point: GridPoint) -> Bool {
        return symbols.contains(grid[point.row][point.col])
    }
    
    func checkAndRefineSelection(_ points: Set<GridPoint>) {
        
        for anomaly in anomalies {
            if anomaly.isSubset(of: points) && !foundAnomalies.contains(anomaly) {
                foundAnomalies.insert(anomaly)
                
                for point in anomaly {
                    grid[point.row][point.col] = String(Int.random(in: 0...9))
                }
            }
        }
    }
    
    func moveViewport(dx: Int, dy: Int) {
        
        let newStepRow = currentSteps.row + dy
        let newStepCol = currentSteps.col + dx
        
        
        guard abs(newStepRow) <= maxSteps && abs(newStepCol) <= maxSteps else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            
            currentSteps = GridPoint(row: newStepRow, col: newStepCol)
            
            
            let newRow = max(0, min(gridSize - viewportSize, viewportOffset.row + dy))
            let newCol = max(0, min(gridSize - viewportSize, viewportOffset.col + dx))
            viewportOffset = GridPoint(row: newRow, col: newCol)
        }
    }
}

struct GridPoint: Hashable {
    let row: Int
    let col: Int
}

struct AnimatedCell: View {
    let content: String
    let cellSize: CGFloat
    let background: Color
    let border: AnyView
    let animation: AudioRefinementState.CellAnimation
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = timeline.date.timeIntervalSinceReferenceDate - animation.startTime
            let time = elapsedTime * 0.8
            
            let angle = (time * animation.speed + animation.phase) * (animation.clockwise ? 1 : -1)
            let x = animation.radius * cos(angle)
            let y = animation.radius * sin(angle)
            
            Text(content)
                .monospacedDigit()
                .frame(width: cellSize, height: cellSize)
                .background(background)
                .overlay(border)
                .offset(x: x, y: y)
        }
    }
}

#Preview {
    AudioRefinementGame(gameState: GameState()) {
        
    }
} 