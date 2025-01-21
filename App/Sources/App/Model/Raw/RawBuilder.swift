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

/// Builds structured content by parsing raw text containing markdown and XML elements
struct RawBuilder {
    /// Raw text buffer containing markdown and XML content to parse
    var buffer: String = ""
    
    /// Container for parsed content items with end-of-message detection
    struct Content {
        /// Array of parsed content items
        var items: [StreamContentItem<ContinuousItem>] = []
        /// Whether end-of-message marker was detected
        var eom: Bool = false
        
        /// Appends markdown content as a continuous item
        /// - Parameters:
        ///   - markdown: The markdown text to append
        ///   - finished: Whether this is the final part of the content
        ///   - ids: Generator for creating unique identifiers
        mutating func append(markdown: some StringProtocol, finished: Bool, ids: inout IdentifierGenerator) {
            let continiousItem = ContinuousItem(
                finished: finished || eom,
                value: .markdown(String(markdown))
            )
            let item = StreamContentItem<ContinuousItem>(ids: &ids, value: continiousItem)
            items.append(item)
        }
        
        /// Appends XML elements as a continuous item
        /// - Parameters:
        ///   - xml: Array of XML elements to append
        ///   - finished: Whether this is the final part of the content
        ///   - ids: Generator for creating unique identifiers
        mutating func append(xml: [XmlElement], finished: Bool, ids: inout IdentifierGenerator) {
            let continiousItem = ContinuousItem(
                finished: finished || eom,
                value: .xml(xml)
            )
            let item = StreamContentItem<ContinuousItem>(ids: &ids, value: continiousItem)
            items.append(item)
        }
        
        /// Appends an error as a continuous item
        /// - Parameters:
        ///   - error: The error to append
        ///   - finished: Whether this is the final part of the content
        ///   - ids: Generator for creating unique identifiers
        mutating func append(error: Error, finished: Bool, ids: inout IdentifierGenerator) {
            let continiousItem = ContinuousItem(
                finished: finished || eom,
                value: .error(IdentifiableError(ids: &ids, underlyingError: error))
            )
            let item = StreamContentItem<ContinuousItem>(ids: &ids, value: continiousItem)
            items.append(item)
        }
    }
    
    /// Represents a continuous item with completion state
    struct ContinuousItem: Equatable {
        /// Whether this item represents complete content
        var finished: Bool
        /// The actual content value
        var value: Item
    }
    
    /// Represents different types of content items that can be parsed
    enum Item: Equatable {
        /// Raw markdown text content
        case markdown(String)
        /// Array of parsed XML elements
        case xml([XmlElement])
        /// Error encountered during parsing
        case error(IdentifiableError)
    }
    
    /// Builds structured content by parsing the buffer into markdown and XML elements
    /// - Returns: A Content object containing the parsed items and end-of-message state
    func build() -> Content {
        var ids: any IdentifierGenerator = IncrementalIdentifierGenerator.create()
        var content = Content()
        var buffer = self.buffer
        
        let eomIndex = buffer.firstRange(of: "<eom>")?.lowerBound
        if let eomIndex {
            let remainingCount = buffer.distance(from: eomIndex, to: buffer.endIndex)
            buffer.removeLast(remainingCount)
            content.eom = true
        }
        while !buffer.isEmpty {
            do {
                let tagNameMatch = try startOfXmlPattern.firstMatch(in: buffer)
                var markdownEndIndex = tagNameMatch?.range.lowerBound ?? buffer.endIndex

                if !content.eom && markdownEndIndex == buffer.endIndex && buffer.last == "<" {
                    markdownEndIndex = buffer.index(before: markdownEndIndex)
                }

                let length = buffer.distance(from: buffer.startIndex, to: markdownEndIndex)
                if length > 0 {
                    let markdown = buffer.prefix(upTo: markdownEndIndex)
                    let finished = markdownEndIndex != buffer.endIndex
                    content.append(markdown: markdown, finished: finished, ids: &ids)
                    buffer.removeSubrange(buffer.startIndex..<markdownEndIndex)
                }
                guard let tagNameInput = tagNameMatch?.output.1 else { break }
                let tagName = String(tagNameInput)
                var endOfXml = buffer.firstRange(of: endOfCompactXmlPattern(tagName: tagName))?.upperBound
                ?? buffer.firstRange(of: endOfXmlPattern(tagName: tagName))?.upperBound
                ?? buffer.endIndex
                if endOfXml >= buffer.endIndex {
                    endOfXml = buffer.index(before: buffer.endIndex)
                }
                let rawXml = buffer.prefix(through: endOfXml)
                buffer.removeSubrange(buffer.startIndex...endOfXml)
                
                let xmlParser = XmlParser(string: rawXml)
                let (elements, error) = xmlParser.parse()
                let finished = endOfXml != buffer.endIndex
                if let elements {
                    content.append(xml: elements, finished: finished, ids: &ids)
                }
                if let error {
                    throw error
                }
            } catch {
                content.append(error: error, finished: !buffer.isEmpty, ids: &ids)
                break
            }
        }
        
        return content
    }
    
    private let startOfXmlPattern = /<(\w+)\b/
    private func endOfCompactXmlPattern(tagName: String) -> Regex<AnyRegexOutput> {
        try! Regex("<\(tagName)\\b[^>]*/>")
    }
    private func endOfXmlPattern(tagName: String) -> Regex<AnyRegexOutput> {
        try! Regex("</\(tagName)>")
    }
    private func startOfXml(_ buffer: String) -> String.Index? {
        // Matches the start of an XML tag:
        // - <abc ...>
        // - <eom>
        // Returns the starting position of the first XML tag if found
        return buffer.firstRange(of: startOfXmlPattern)?.lowerBound
    }
}
