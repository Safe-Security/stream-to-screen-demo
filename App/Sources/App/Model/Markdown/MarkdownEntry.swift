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
import MarkdownUI

/// Represents a markdown entry that can have both full and collapsed content states
struct MarkdownEntry: Equatable, Sendable {
    /// The full markdown content
    var content: MarkdownContent
    /// Optional collapsed version of the content
    var collapsed: MarkdownContent?
    /// Raw string representation of the full content
    var rawContent: String
    /// Optional raw string representation of the collapsed content
    var rawCollapsed: String?
    /// Whether this entry can be collapsed
    var collapsable: Bool {
        collapsed != nil
    }
    
    /// Hashes the essential properties of the entry
    /// - Parameter hasher: The hasher to use
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawContent)
        hasher.combine(rawCollapsed)
    }
    
    /// Compares two markdown entries for equality
    /// - Parameters:
    ///   - lhs: Left hand side entry
    ///   - rhs: Right hand side entry
    /// - Returns: Whether the entries are equal
    static func ==(lhs: MarkdownEntry, rhs: MarkdownEntry) -> Bool {
        lhs.rawContent == rhs.rawContent
        && lhs.rawCollapsed == rhs.rawCollapsed
    }
}

extension MarkdownContent: @unchecked @retroactive Sendable {}

/// Builds markdown entries from block nodes with support for collapsible content
struct MarkdownEntryBuilder {
    /// The block nodes that make up the entry content
    var blocks: [BlockNode] = []
    
    /// Creates a collapsed version of the content by truncating sections
    /// - Returns: A collapsed version of the content, or nil if not collapsible
    private func collapsed() -> MarkdownContent? {
        let sections = blocks.chunked { node in
            // Split on headings
            if case .heading = node {
                true
            } else {
                false
            }
        }
        // Collapse each section separately
        let truncatedSections = sections.map { nodes -> String in
            var blocks: [BlockNode] = []
            for block in nodes.1 {
                blocks.append(block)
                if case .paragraph = block {
                    break
                }
            }
            let didTruncated = blocks.count < nodes.1.count
            let truncated = MarkdownContent(blocks: blocks).renderMarkdown() + (didTruncated ? " .." : "")
            return truncated
        }

        let result = MarkdownContent(truncatedSections.joined(separator: "\n"))
        return result
    }
    
    /// Cleans up partial paragraphs from the end of the content
    mutating func cleanup() {
        while !blocks.isEmpty {
            let lastParagraphIsPartial: Bool
            if case .paragraph(content: let content) = blocks.last {
                lastParagraphIsPartial = content.contains { node in
                    guard case .text(let string) = node else {
                        return false
                    }
                    return string.contains("|")
                }
            } else {
                lastParagraphIsPartial = false
            }
            guard lastParagraphIsPartial else {
                break
            }
            blocks.removeLast()
        }
    }
    
    /// Builds a markdown entry from the current blocks
    /// - Returns: A markdown entry if there are blocks to build from, nil otherwise
    func build() -> MarkdownEntry? {
        guard !blocks.isEmpty else { return nil }
        let content = MarkdownContent(blocks: blocks)
        let rawContent = content.renderMarkdown()
        var collapsed = collapsed()
        var rawCollapsed = collapsed?.renderMarkdown()
        
        if rawContent.count <= (rawCollapsed?.count ?? 0) + 20 {
            collapsed = nil
            rawCollapsed = nil
        }
        
        return MarkdownEntry(
            content: content,
            collapsed: collapsed,
            rawContent: rawContent,
            rawCollapsed: rawCollapsed
        )
    }
}
