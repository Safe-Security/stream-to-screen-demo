import SwiftUI
import MarkdownUI

struct MarkdownTableView: View {
    let table: MarkdownTable
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 10) {
                    ForEach(table.cards) { card in
                        CardView(card: card.value, maxRows: table.maxRowCount)
                            .containerRelativeFrame(
                                .horizontal,
                                count: 1,
                                spacing: 10,
                                alignment: .trailing
                            )
                    }
                }
                .scrollTargetLayout()
                .id("content")
                .animation(.default, value: table.cards.last)
            }
            .scrollTargetBehavior(.viewAligned)
            .onChange(of: table.cards.last) {
                withAnimation(.linear(duration: 0.2)) {
                    proxy.scrollTo("content", anchor: .trailing)
                }
            }
        }
        .scrollClipDisabled()
        .safeAreaPadding(.horizontal)
    }
}

private struct CardView: View {
    let card: MarkdownTable.Card
    let maxRows: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(card.rows) { row in
                RowView(row: row.value)
            }
            .frame(height: 44)
        }
        .frame(height: CGFloat(maxRows) * 44, alignment: .topLeading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

private struct RowView: View {
    let row: MarkdownTable.Row
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                if let title = row.title {
                    switch title {
                    case .cell(let cell):
                        Markdown(cell.value)
                            .markdownTextStyle {
                                ForegroundColor(.secondary)
                            }
                            .fixedSize()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    Color.clear
                }
                if let value = row.value {
                    switch value {
                    case .cell(let cell):
                        Markdown(cell.value)
                    }
                } else {
                    Color.clear
                }
            }
        }
    }
}
