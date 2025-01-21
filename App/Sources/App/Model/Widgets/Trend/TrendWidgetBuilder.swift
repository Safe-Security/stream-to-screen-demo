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

/// Represents a widget that displays trend data for risk scenarios over time
struct TrendWidget: Equatable, Sendable, Decodable {
    var riskScenarioName: String?
    var trendData: [TrendData]?
    
    /// Represents a single data point in a trend, containing likelihood and timestamp information
    struct TrendData: Equatable, Sendable, Decodable {
        var eventLikelihood: Double?
        var timestamp: Date?

        enum CodingKeys: String, CodingKey {
            case eventLikelihood
            case timestamp
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            eventLikelihood = try container.decodeIfPresent(Double.self, forKey: .eventLikelihood)
            timestamp = try? container.decodeIfPresent(Date.self, forKey: .timestamp)
        }
    }
}

/// Parses XML elements into TrendWidget instances by extracting and decoding JSON data
struct TrendParser {
    var element: XmlElement
    
    /// Attempts to parse an XML element into a TrendWidget by extracting and decoding JSON from the SafeVizSummary child element
    /// - Parameter ids: Generator for creating unique identifiers
    /// - Returns: A parsed TrendWidget if valid JSON data is found, nil otherwise
    /// - Throws: Decoding errors if the JSON data is invalid
    func parse(ids nestedIds: inout IdentifierGenerator) throws -> TrendWidget? {
        let summaryElement = element.children.first { $0.name == "SafeVizSummary" }
        guard let summary = summaryElement?.text, !summary.isEmpty else { return TrendWidget() }
        let decoder = JSONDecoder.default
        let validJson: String
        if summaryElement?.completed == true {
            validJson = summary
        } else {
            validJson = JsonCompleter().complete(json: summary)
        }
        
        let content = try decoder.decode(TrendWidget.self, from: Data(validJson.utf8))
        return content
    }
}
