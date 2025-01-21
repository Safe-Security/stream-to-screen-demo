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

/// Container for page-level options and controls
struct Options: Equatable, Sendable {
    var page = Page()
    
    /// Represents page-specific options and control values
    struct Page: Equatable, Sendable {
        /// Optional control value indicating page action/state
        var control: PageControlValue?
    }
}

/// Defines possible control values for page actions
enum PageControlValue: String, Equatable, Sendable {
    /// Indicates page should be submitted
    case submit
}

/// Builds structured options from stream content by parsing XML elements
struct OptionBuilder {
    /// The stream content to parse options from
    var input: StreamContent
    
    /// Builds a new stream content by parsing option elements from XML
    /// - Parameter nestedIds: Generator for creating unique identifiers
    /// - Returns: A new stream content with parsed options
    func build(ids nestedIds: IdentifierGenerator) -> StreamContent {
        var ids = nestedIds
        var content = input
        content.items.removeAll(keepingCapacity: true)
        
        for item in input.items {
            switch item.value {
            case .xml(let xml):
                for element in xml {
                    let parsed = OptionParser(element: element).parse(ids: &ids, options: &content.options)
                    if !parsed {
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
