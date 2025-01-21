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

/// Represents a stream of content items with state information and form handling capabilities
struct StreamContent: Equatable, Sendable {
    /// Array of content items in the stream
    var items: [Item] = []
    /// Whether the stream has finished receiving content
    var finished: Bool = false
    /// Collection of errors encountered during stream processing
    var errors: [IdentifiableError] = []
    /// Stream configuration options
    var options = Options()
    
    typealias Item = StreamContentItem<StreamItemValue>
    
    /// Replaces the value of the last item in the stream with a new value
    /// - Parameter newValue: The new value to set for the last item
    mutating func replaceLastValue(_ newValue: StreamItemValue) {
        items[safe: items.count - 1]?.value = newValue
    }
    
    /// Extracts form input values from the stream content
    /// - Parameter submit: Optional input representing the submit button that was pressed
    /// - Returns: Dictionary mapping input names to their values for hidden fields and the submitted button
    func inputs(submit: Input? = nil) -> [String: String] {
        var form: [String: String] = [:]
        for item in items {
            switch item.value {
            case .input(let input):
                switch input.content {
                case .hidden:
                    form[input.name] = input.value
                case .button where input.name == submit?.name:
                    form[input.name] = input.value
                default:
                    continue
                }
            default:
                continue
            }
        }
        return form
    }
}

/// A uniquely identifiable content item in the stream
struct StreamContentItem<Value: Equatable>: Identifiable, Equatable {
    /// Unique identifier for the content item
    var id: IdentifierGenerator.ID
    /// The value contained by this item
    var value: Value
    
    /// Creates a new content item with a unique identifier
    /// - Parameters:
    ///   - ids: Generator for creating unique identifiers
    ///   - value: The value to store in this item
    init(ids: inout IdentifierGenerator, value: Value) {
        self.id = ids()
        self.value = value
    }
}

extension StreamContentItem: Sendable where Value: Sendable {}

/// Represents the different types of content that can appear in a stream
enum StreamItemValue: Equatable, Sendable {
    /// Markdown formatted text content
    case markdown(MarkdownEntry)
    /// Tabular data formatted in markdown
    case markdownTable(MarkdownTable)
    /// Interactive question element
    case question(Question)
    /// Group of related questions
    case questionGroup(QuestionGroup)
    /// Raw XML elements
    case xml([XmlElement])
    /// Interactive widget element
    case widget(Widget)
    /// Container for organizing other widgets
    case container(ContainerWidget)
    /// Form input element
    case input(Input)
}
