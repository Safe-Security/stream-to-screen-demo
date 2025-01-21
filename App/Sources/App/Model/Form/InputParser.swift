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

/// Parses XML elements into Input objects
struct InputParser {
    /// The XML element to parse
    var element: XmlElement
    
    /// Parses the XML element into an Input object if it represents a valid input element
    /// - Parameter ids: Generator for creating unique identifiers
    /// - Returns: An Input object if the XML element represents a valid input, nil otherwise
    func parse(ids: inout IdentifierGenerator) -> Input? {
        guard element.name == "SafeInput" else { return nil }
        let name = element.attributes["name"]
        let rawType = element.attributes["type"]
        guard let name, let rawType else { return nil }
        
        switch rawType {
        case "hidden":
            return .init(
                name: name,
                value: element.attributes["value"],
                content: .hidden
            )
        case "button":
            let label = element.text
            guard !label.isEmpty else { return nil }
            return .init(
                name: name,
                value: element.attributes["value"],
                content: .button(name: label)
            )
        case "appearance":
            let runImmediately = element.attributes["runImmediately"]?.lowercased() == "true"
            return .init(
                name: name,
                value: element.attributes["value"],
                content: .appearance(
                    text: element.text,
                    runImmediately: runImmediately,
                    ready: element.completed
                )
            )
        default:
            return nil
        }
    }
}
