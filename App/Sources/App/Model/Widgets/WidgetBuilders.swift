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

/// A container widget that holds a collection of child widgets and any parsing errors
struct ContainerWidget: Equatable, Sendable {
    var widgets: [StreamContentItem<Widget>] = []
    var errors: [IdentifiableError] = []
}

/// Represents different types of widgets that can be displayed in the stream
enum Widget: Equatable, Sendable {
    case trend(TrendWidget)
}

/// Parses XML elements into container widgets with their child widgets
struct ContainerParser {
    var element: XmlElement
    
    /// Attempts to parse an XML element into a container widget
    /// - Parameter ids: Generator for creating unique identifiers
    /// - Returns: A parsed container widget if the element represents a valid container, nil otherwise
    func parse(ids: inout IdentifierGenerator) -> ContainerWidget? {
        guard element.name == "SafeContainer" else { return nil }
        
        var container = ContainerWidget()
        for child in element.children {
            do {
                if let widget = try WidgetParser(element: child).parse(ids: &ids) {
                    container.widgets.append(.init(ids: &ids, value: widget))
                }
            } catch {
                container.errors.append(IdentifiableError(ids: &ids, underlyingError: error))
            }
        }
        return container
    }
}

/// Parses XML elements into specific widget types
struct WidgetParser {
    var element: XmlElement
    
    /// Attempts to parse an XML element into a specific widget type
    /// - Parameter ids: Generator for creating unique identifiers
    /// - Returns: A parsed widget if the element represents a valid widget, nil otherwise
    /// - Throws: Errors encountered during widget parsing
    func parse(ids: inout IdentifierGenerator) throws -> Widget? {
        guard element.name == "SafeViz",
              let name = element.attributes["name"]
        else { return nil }
        
        switch name {
        case "LIKB":
            if let trend = try TrendParser(element: element).parse(ids: &ids) {
                return .trend(trend)
            }
        default:
            break
        }
        
        return nil
    }
}

/// Processes stream content to build and organize widgets from XML elements
struct WidgetBuilder {
    var input: StreamContent
    
    /// Builds widgets from XML elements in the stream content
    /// - Parameter ids: Generator for creating unique identifiers
    /// - Returns: Stream content with XML elements converted to appropriate widget types
    func build(ids nestedIds: IdentifierGenerator) -> StreamContent {
        var ids = nestedIds
        var content = input
        content.items.removeAll(keepingCapacity: true)
        
        for item in input.items {
            switch item.value {
            case .xml(let elements):
                for element in elements {
                    do {
                        if var container = ContainerParser(element: element).parse(ids: &ids) {
                            content.errors.append(contentsOf: container.errors)
                            container.errors.removeAll()
                            content.items.append(.init(ids: &ids, value: .container(container)))
                        } else if let widget = try WidgetParser(element: element).parse(ids: &ids) {
                            content.items.append(.init(ids: &ids, value: .widget(widget)))
                        } else {
                            content.items.append(item)
                        }
                    } catch {
                        content.errors.append(IdentifiableError(ids: &ids, underlyingError: error))
                    }
                }
            default:
                content.items.append(item)
            }
        }
        
        return content
    }
}
