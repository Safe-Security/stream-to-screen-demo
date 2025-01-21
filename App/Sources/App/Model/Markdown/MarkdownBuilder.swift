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

import MarkdownUI
import Foundation
import Algorithms

/// Builds structured content from raw markdown text by parsing and organizing it into tables and markdown entries
struct MarkdownBuilder {
    /// The raw markdown text to be parsed
    var rawMarkdown: any StringProtocol

    /// Container for parsed markdown content items including tables and markdown entries
    struct Content {
        /// Array of content items that can be either markdown tables or markdown entries
        var items: [StreamContentItem<StreamItemValue>] = []
        
        /// Appends a markdown table to the content items
        /// - Parameters:
        ///   - table: The markdown table to append
        ///   - ids: Generator for creating unique identifiers
        mutating func append(table: MarkdownTable, ids: inout any IdentifierGenerator) {
            let item = StreamContentItem<StreamItemValue>(ids: &ids, value: .markdownTable(table))
            items.append(item)
        }

        /// Appends a markdown entry to the content items
        /// - Parameters:
        ///   - markdown: The markdown entry to append
        ///   - ids: Generator for creating unique identifiers
        mutating func append(markdown: MarkdownEntry, ids: inout any IdentifierGenerator) {
            let item = StreamContentItem<StreamItemValue>(ids: &ids, value: .markdown(markdown))
            items.append(item)
        }
    }
    
    /// Removes leading and trailing whitespace and newlines from the raw markdown
    mutating func cleanup() {
        rawMarkdown = rawMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Builds structured content from the raw markdown by parsing it into tables and markdown entries
    /// - Parameter nestedIds: Generator for creating unique identifiers
    /// - Returns: A Content object containing the parsed markdown as structured items
    func build(ids nestedIds: IdentifierGenerator) -> Content {
        var ids = nestedIds
        var content = Content()
        let markdown = MarkdownContent(String(rawMarkdown))
        var markdownBuilder = MarkdownEntryBuilder()
        for block in markdown.blocks {
            let table = MarkdownTableBuilder(node: block).build(ids: ids.nested())
            if let table {
                let markdown = markdownBuilder.build()
                if let markdown {
                    content.append(markdown: markdown, ids: &ids)
                    markdownBuilder.blocks = []
                }
                content.append(table: table, ids: &ids)
            } else {
                markdownBuilder.blocks.append(block)
            }
        }
        
        markdownBuilder.cleanup()
        
        if let markdown = markdownBuilder.build() {
            content.append(markdown: markdown, ids: &ids)
        }
        return content
    }
}
