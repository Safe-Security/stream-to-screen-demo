// Copyright © 2025 Safe Security
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this Project ("Software") from Safe Security, to use it solely for personal learning and internal demonstration.
// 
// **Restrictions:**
// 1. The Software may not be redistributed, sublicensed, or used commercially without prior written consent from Safe Security.
// 2. You must not remove or alter any copyright or proprietary notices.
// 3. You must not use this Software (or derivatives) in any way that harms, competes with, or discredits Safe Security.
// 
// THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND. IN NO EVENT SHALL SAFE SECURITY BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR ITS USE.

import Foundation
@preconcurrency import MarkdownUI

/// Represents a markdown table with cards containing rows of content
struct MarkdownTable: Equatable, Sendable {
    /// Array of cards that make up the table
    var cards: [StreamContentItem<Card>] = []
    /// Maximum number of rows in any card
    var maxRowCount: Int = 0

    /// Represents a card within the table containing rows of content
    struct Card: Equatable, Sendable {
        /// Array of rows in this card
        var rows: [StreamContentItem<Row>]
    }

    /// Represents a row within a card containing title and value content
    struct Row: Equatable, Sendable {
        /// Optional title content for the row
        var title: RowContent?
        /// Optional value content for the row
        var value: RowContent?
    }

    /// Represents the content of a row cell
    enum RowContent: Equatable, Sendable {
        /// Cell containing markdown content
        case cell(CellContent)
    }
    
    /// Represents the content of an individual table cell
    struct CellContent: Equatable, Sendable {
        /// Raw string value of the cell content
        var rawValue: String
        /// Markdown content of the cell
        var value: MarkdownContent
        
        /// Creates a new cell content from markdown content
        /// - Parameter value: The markdown content for the cell
        init(_ value: MarkdownContent) {
            self.value = value
            self.rawValue = value.renderMarkdown()
        }
        
        /// Hashes the essential properties of the cell content
        /// - Parameter hasher: The hasher to use
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
        
        /// Compares two cell contents for equality
        /// - Parameters:
        ///   - lhs: Left hand side cell content
        ///   - rhs: Right hand side cell content
        /// - Returns: Whether the cell contents are equal
        static func == (lhs: CellContent, rhs: CellContent) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
    }
}

extension InlineNode: @unchecked @retroactive Sendable {}

/// Builds markdown tables from block nodes
struct MarkdownTableBuilder {
    /// The block node to build the table from
    var node: BlockNode
    
    /// Builds a markdown table from the block node
    /// - Parameter ids: Generator for creating unique identifiers
    /// - Returns: A markdown table if the node represents a valid table, nil otherwise
    func build(ids nestedIds: any IdentifierGenerator) -> MarkdownTable? {
        guard case .table(_, let rows) = node else { return nil }
        var ids = nestedIds
        var table = MarkdownTable()
        var headings: [MarkdownTable.RowContent] = []
        for (offset, row) in rows.enumerated() {
            if offset == 0 {
                // heading
                headings = row.cells.map { cell in
                    let content = MarkdownContent(block: .paragraph(content: cell.content))
                    return MarkdownTable.RowContent.cell(.init(content))
                }
                continue
            }
            var card = MarkdownTable.Card(rows: [])
            for (index, cell) in row.cells.enumerated() {
                var row = MarkdownTable.Row()
                row.title = headings[safe: index]
                let content = MarkdownContent(block: .paragraph(content: cell.content))
                row.value = MarkdownTable.RowContent.cell(.init(content))
                card.rows.append(.init(ids: &ids, value: row))
            }
            table.cards.append(.init(ids: &ids, value: card))
        }
        table.maxRowCount = headings.count
        if table.cards.isEmpty {
            var card = MarkdownTable.Card(rows: [])
            for heading in headings {
                var row = MarkdownTable.Row()
                row.title = heading
                row.value = .cell(.init(.init(block: .paragraph(content: [.text("")]))))
                card.rows.append(.init(ids: &ids, value: row))
            }
            table.cards.append(.init(ids: &ids, value: card))
        }
        return table
    }
}
