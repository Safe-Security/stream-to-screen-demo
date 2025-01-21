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

/// Represents an input element with a name, optional value and content type
struct Input: Equatable, Sendable {
    let name: String
    let value: String?
    let content: InputContent
}

/// Defines the different types of input content that can be displayed
enum InputContent: Equatable, Sendable {
    /// A hidden input that is not visible to the user
    case hidden
    /// A button input with a display name
    case button(name: String)
    /// An appearance toggle with target state and runImmediately flag
    case appearance(text: String, runImmediately: Bool, ready: Bool)
}

/// Builds input elements from stream content by parsing XML elements
struct InputBuilder {
    var input: StreamContent
    
    /// Adds an input element to the stream content
    /// - Parameters:
    ///   - input: The input element to add
    ///   - content: The stream content to add the input to
    ///   - ids: Generator for creating unique identifiers
    func add(input: Input, content: inout StreamContent, ids: inout IdentifierGenerator) {
        let item = StreamContent.Item(ids: &ids, value: .input(input))
        content.items.append(item)
    }
    
    /// Builds a new stream content by parsing input elements from XML
    /// - Parameter nestedIds: Generator for creating unique identifiers
    /// - Returns: A new stream content with parsed input elements
    func build(ids nestedIds: IdentifierGenerator) -> StreamContent {
        var ids = nestedIds
        var content = input
        content.items.removeAll(keepingCapacity: true)
        
        for item in input.items {
            switch item.value {
            case .xml(let xml):
                for element in xml {
                    let input = InputParser(element: element).parse(ids: &ids)
                    if let input {
                        add(input: input, content: &content, ids: &ids)
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
