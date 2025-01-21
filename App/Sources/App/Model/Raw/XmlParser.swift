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

/// Parses XML content into structured elements using NSXMLParser
final class XmlParser: NSObject, XMLParserDelegate {
    private var current: RawXmlElement?
    let string: any StringProtocol
    
    /// Creates a new XML parser for the given string content
    /// - Parameter string: The XML string content to parse
    init(string: some StringProtocol) {
        self.string = string
    }
    
    /// Parses the XML content into an array of structured elements
    /// - Returns: A tuple containing the parsed XML elements and any parsing error that occurred
    func parse() -> ([XmlElement]?, Error?) {
        let parser = XMLParser(data: Data(string.utf8))
        parser.shouldResolveExternalEntities = false
        parser.externalEntityResolvingPolicy = .never
        parser.delegate = self
        let root = RawXmlElement()
        current = root
        parser.parse()
        current = nil
        let children = root.build().children
        
        return (children, parser.parserError)
    }
    
    /// Handles completion of an XML element during parsing
    /// - Parameters:
    ///   - parser: The XML parser
    ///   - elementName: Name of the completed element
    ///   - namespaceURI: Optional namespace URI
    ///   - qName: Optional qualified name
    public func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        self.current = self.current?.pop(elementName)
    }

    /// Handles start of a new XML element during parsing
    /// - Parameters:
    ///   - parser: The XML parser
    ///   - elementName: Name of the new element
    ///   - namespaceURI: Optional namespace URI
    ///   - qName: Optional qualified name
    ///   - attributeDict: Dictionary of element attributes
    public func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        self.current = self.current?.push(elementName)
        self.current?.attributes = attributeDict
    }

    /// Handles text content found between XML tags
    /// - Parameters:
    ///   - parser: The XML parser
    ///   - string: The text content
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.current?.text += string
    }
}

/// Represents a parsed XML element with its properties and child elements
struct XmlElement: Equatable {
    /// Optional name of the XML element
    var name: String?
    /// Text content between the element's tags
    var text: String = ""
    /// Dictionary of element attributes
    var attributes: [String: String] = [:]
    /// Array of child XML elements
    var children: [XmlElement] = []
    /// Whether the element has been fully parsed
    var completed: Bool = false
}

/// Internal representation of an XML element during parsing
fileprivate final class RawXmlElement {
    weak var parent: RawXmlElement?
    var name: String?
    var text: String = ""
    var attributes: [String: String] = [:]
    var children: [RawXmlElement] = []
    var completed: Bool = false
    
    init(_ parent: RawXmlElement? = nil, name: String = "") {
        self.parent = parent
        self.name = name
    }

    func push(_ elementName: String) -> RawXmlElement {
        let childElement = RawXmlElement(self, name: elementName)
        children.append(childElement)
        return childElement
    }

    func pop(_ elementName: String) -> RawXmlElement? {
        assert(elementName == self.name)
        completed = true
        return self.parent
    }
    
    func build() -> XmlElement {
        var element = XmlElement()
        element.name = name
        element.text = text
        element.attributes = attributes
        element.children = children.map { $0.build() }
        element.completed = completed
        return element
    }
}
