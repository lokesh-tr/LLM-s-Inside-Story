import SwiftUI

struct InfoCard: View {
    let title: String
    let description: String
    let systemImage: String
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 16 : 12) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(horizontalSizeClass == .regular ? .title : .title2)
                    .foregroundStyle(.blue)
                
                Text(title)
                    .font(horizontalSizeClass == .regular ? .title2 : .title3)
                    .bold()
            }
            
            Text(description)
                .font(horizontalSizeClass == .regular ? .title3 : .body)
                .foregroundStyle(.secondary)
        }
        .padding(horizontalSizeClass == .regular ? 24 : 16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        }
    }
}

#Preview {
    InfoCard(
        title: "Sample Card",
        description: "This is a sample info card with a description that might span multiple lines to demonstrate the layout.",
        systemImage: "star.fill"
    )
    .padding()
}
