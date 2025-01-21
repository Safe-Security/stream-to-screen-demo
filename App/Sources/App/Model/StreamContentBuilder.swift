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

/// Builds structured stream content by processing raw content and applying various content builders
struct StreamContentBuilder {
    /// Raw text buffer containing content to be processed
    var buffer: String = ""
    
    /// Processes raw content into structured stream content with unique identifiers
    /// - Parameters:
    ///   - raw: The raw content to process
    ///   - ids: Generator for creating unique identifiers
    /// - Returns: Processed stream content with markdown, XML and errors
    func buildContent(raw: RawBuilder.Content, ids nestedIds: IdentifierGenerator) -> StreamContent {
        var ids = nestedIds
        var content = StreamContent()
        content.finished = raw.eom
        
        for rawItem in raw.items {
            switch rawItem.value.value {
            case .markdown(let markdown):
                var builder = MarkdownBuilder(rawMarkdown: markdown)
                if content.finished {
                    builder.cleanup()
                }
                content.items.append(contentsOf: builder.build(ids: ids.nested()).items)
                break
            case .xml(let xml):
                content.items.append(.init(ids: &ids, value: .xml(xml)))
                break
            case .error(let error):
                if rawItem.value.finished {
                    content.errors.append(error)
                }
                break
            }
        }
        return content
    }
    
    /// Builds the final stream content by processing raw content through multiple specialized builders
    /// - Returns: Fully processed stream content with all content types handled
    func build() -> StreamContent {
//        print("\(buffer.count)")
        let raw = RawBuilder(buffer: buffer).build()
        
        var ids: any IdentifierGenerator = IncrementalIdentifierGenerator.create()
        var content = buildContent(raw: raw, ids: ids.nested())
        content = OptionBuilder(input: content).build(ids: ids.nested())
        content = InputBuilder(input: content).build(ids: ids.nested())
        content = QuestionBuilder(input: content).build(ids: ids.nested())
        content = WidgetBuilder(input: content).build(ids: ids.nested())
       
        return content
    }
}
