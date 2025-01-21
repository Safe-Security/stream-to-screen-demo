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

/// Processes stream content to build and organize questions and question groups from XML elements
struct QuestionBuilder {
    var input: StreamContent
    
    /// Adds a question to the stream content, either as a standalone question or part of a question group
    /// - Parameters:
    ///   - question: The question to add
    ///   - content: Stream content to modify
    ///   - ids: Generator for creating unique identifiers
    func add(
        question: Question,
        content: inout StreamContent,
        ids: inout IdentifierGenerator
    ) {
        let last = content.items.last
        switch last?.value {
        case .questionGroup(var group):
            group.questions.append(.init(ids: &ids, value: question))
            content.replaceLastValue(.questionGroup(group))
        case .question(let previousQuestion):
            let questions = [previousQuestion, question]
                .map { StreamContentItem(ids: &ids, value: $0) }
            let group = QuestionGroup(questions: questions)
            content.items.removeLast()
            add(group: group, content: &content, ids: &ids)
        default:
            let item = StreamContent.Item(ids: &ids, value: .question(question))
            content.items.append(item)
        }
    }
    
    /// Adds a question group to the stream content, optionally extracting its title from preceding markdown heading
    /// - Parameters:
    ///   - group: The question group to add
    ///   - content: Stream content to modify
    ///   - ids: Generator for creating unique identifiers
    func add(
        group: QuestionGroup,
        content: inout StreamContent,
        ids: inout IdentifierGenerator
    ) {
        guard group.title == nil,
              let last = content.items.last,
              case .markdown(let entry) = last.value,
              case .heading(_, let heading) = entry.content.blocks.last
        else {
            let item = StreamContent.Item(ids: &ids, value: .questionGroup(group))
            content.items.append(item)
            return
        }
        
        var blocks = entry.content.blocks
        blocks.removeLast()
        let newEntry = MarkdownEntryBuilder(blocks: blocks).build()
        if let newEntry {
            content.replaceLastValue(.markdown(newEntry))
        }
        
        var newGroup = group
        newGroup.title = MarkdownContent(block: .paragraph(content: heading)).renderPlainText()
        if newEntry == nil {
            content.replaceLastValue(.questionGroup(newGroup))
        } else {
            let item = StreamContent.Item(ids: &ids, value: .questionGroup(newGroup))
            content.items.append(item)
        }
    }
    
    /// Builds questions and question groups from XML elements in the stream content
    /// - Parameter ids: Generator for creating unique identifiers
    /// - Returns: Stream content with XML elements converted to appropriate question types
    func build(ids nestedIds: IdentifierGenerator) -> StreamContent {
        var ids = nestedIds
        var content = input
        content.items.removeAll(keepingCapacity: true)
        
        for item in input.items {
            switch item.value {
            case .xml(let xml):
                for element in xml {
                    if let question = QuestionParser(element: element).parse(ids: &ids) {
                        add(question: question, content: &content, ids: &ids)
                    } else if let group = QuestionGroupParser(element: element).parse(ids: &ids) {
                        add(group: group, content: &content, ids: &ids)
                    } else {
                        content.items.append(item)
                    }
                }
            default:
                content.items.append(item)
            }
        }
        
        return content
    }
}
