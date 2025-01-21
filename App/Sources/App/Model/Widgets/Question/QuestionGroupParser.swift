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

/// A container for grouping related questions together with an optional title
struct QuestionGroup: Equatable, Sendable {
    var title: String?
    var questions: [StreamContentItem<Question>] = []
}

/// Parses XML elements into QuestionGroup instances by extracting questions and title
struct QuestionGroupParser {
    var element: XmlElement
    
    /// Attempts to parse an XML element into a QuestionGroup by extracting child questions and title
    /// - Parameter ids: Generator for creating unique identifiers
    /// - Returns: A parsed QuestionGroup if valid questions are found, nil otherwise
    func parse(ids: inout IdentifierGenerator) -> QuestionGroup? {
        guard element.name == "SafeQuestionGroup" else { return nil }
        let title = element.attributes["title"]
        let questions = element.children.compactMap { QuestionParser(element: $0).parse(ids: &ids) }
        guard !questions.isEmpty else { return nil }
        let items = questions.map { StreamContentItem(ids: &ids, value: $0) }
        return QuestionGroup(title: title, questions: items)
    }
}
