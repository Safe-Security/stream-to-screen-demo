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

/// Parses XML elements into structured options by extracting and validating option attributes
struct OptionParser {
    /// The XML element to parse options from
    var element: XmlElement
    
    /// Attempts to parse the XML element into structured options
    /// - Parameters:
    ///   - ids: Generator for creating unique identifiers
    ///   - options: The options container to update with parsed values
    /// - Returns: Whether the element was successfully parsed as an option
    func parse(ids: inout IdentifierGenerator, options: inout Options) -> Bool {
        guard element.name == "SafeOption" else { return false }
        let name = element.attributes["name"]
        let value = element.attributes["value"]
        guard let name, let value else { return false }
        
        switch name {
        case "page.control":
            guard let data = PageControlValue(rawValue: value) else { return false }
            options.page.control = data
            return true
        default:
            return false
        }
    }
}
