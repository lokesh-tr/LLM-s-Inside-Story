import SwiftUI

struct ProgressDots: View {
    let currentStep: Int
    let stepCount: Int
    let isPad: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<stepCount, id: \.self) { index in
                Circle()
                    .fill(index == currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: isPad ? 12 : 8, height: isPad ? 12 : 8)
            }
        }
    }
}

#Preview {
    ProgressDots(currentStep: 1, stepCount: 4, isPad: true)
        .padding()
} 