import SwiftUI

struct TokenView: View {
    let token: Token
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Text(token.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color(uiColor: .secondarySystemBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                    }
            }
            .onTapGesture {
                onTap?()
            }
    }
}

struct MergeRuleView: View {
    let rule: MergeRule
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(rule.from)
                    .font(.system(.body, design: .monospaced))
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
                Text(rule.to)
                    .font(.system(.body, design: .monospaced))
            }
            
            Text(rule.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color(uiColor: .secondarySystemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                }
        }
        .onTapGesture {
            onTap?()
        }
    }
}

struct TokenDropArea: View {
    let tokens: [Token]
    
    var body: some View {
        HStack {
            if tokens.isEmpty {
                Text("Drop tokens here")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(tokens) { token in
                    TokenView(token: token)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .tertiarySystemBackground))
        }
    }
}

struct TokenizationComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TokenView(token: Token(characters: Array("hello"), isHighlighted: false))
            
            MergeRuleView(rule: MergeRule(
                from: "h e",
                to: "he",
                description: "Common letter pair",
                explanation: "I notice these letters often appear together at the start of words"
            ))
            
            TokenDropArea(tokens: [
                Token(characters: Array("hello"), isHighlighted: false),
                Token(characters: Array("world"), isHighlighted: false)
            ])
        }
        .padding()
    }
} 