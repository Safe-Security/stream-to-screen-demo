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

/// A utility struct for completing partial JSON strings by adding missing closing characters
struct JsonCompleter {
    /// Defines which JSON value types are allowed during completion
    struct Allow: OptionSet {
        let rawValue: Int
        
        static let string = Allow(rawValue: 1 << 0)
        static let number = Allow(rawValue: 1 << 1)
        static let array = Allow(rawValue: 1 << 2)
        static let object = Allow(rawValue: 1 << 3)
        static let null = Allow(rawValue: 1 << 4)
        static let boolean = Allow(rawValue: 1 << 5)
        
        /// All JSON value types allowed
        static let all: Allow = [.string, .number, .array, .object, .null, .boolean]
    }
    
    private func skipWhitespace(_ json: String, from index: String.Index) -> String.Index {
        var current = index
        while current < json.endIndex && json[current].isWhitespace {
            current = json.index(after: current)
        }
        return current
    }
    
    private func completeString(_ json: String, from startIndex: String.Index, allow: Allow) -> (endIndex: String.Index, completion: String?) {
        guard startIndex < json.endIndex, json[startIndex] == "\"" else { return (startIndex, nil) }
        
        var current = json.index(after: startIndex)
        var isEscaped = false
        
        while current < json.endIndex {
            let char = json[current]
            if char == "\\" {
                isEscaped.toggle()
            } else if char == "\"" && !isEscaped {
                return (json.index(after: current), nil) // Complete string
            } else {
                isEscaped = false
            }
            current = json.index(after: current)
        }
        
        // String is incomplete
        return allow.contains(.string) ? (current, "\"") : (startIndex, nil)
    }
    
    private func completeArray(_ json: String, from startIndex: String.Index, allow: Allow) -> (endIndex: String.Index, completion: String?) {
        guard startIndex < json.endIndex, json[startIndex] == "[" else { return (startIndex, nil) }
        
        var current = json.index(after: startIndex)
        var lastComma: String.Index?
        
        while current < json.endIndex {
            current = skipWhitespace(json, from: current)
            if current >= json.endIndex { break }
            
            if json[current] == "]" {
                return (json.index(after: current), nil) // Complete array
            }
            
            let valueResult = completeAny(json, from: current, allow: allow)
            if let completion = valueResult.completion {
                return (valueResult.endIndex, completion + "]")
            } else {
                lastComma = nil
            }
            
            current = skipWhitespace(json, from: valueResult.endIndex)
            if current >= json.endIndex { break }
            
            if json[current] == "," {
                lastComma = current
                current = json.index(after: current)
            }
        }
        return allow.contains(.array) ? (lastComma ?? current, "]") : (startIndex, nil)
    }
    
    private func completeObject(_ json: String, from startIndex: String.Index, allow: Allow) -> (endIndex: String.Index, completion: String?) {
        guard startIndex < json.endIndex, json[startIndex] == "{" else { return (startIndex, nil) }
        
        var current = json.index(after: startIndex)
        var lastComma: String.Index? = current
        while current < json.endIndex {
            current = skipWhitespace(json, from: current)
            if current >= json.endIndex { break }
            
            if json[current] == "}" {
                return (json.index(after: current), nil) // Complete object
            }
            
            // Parse key
            let keyResult = completeString(json, from: current, allow: allow)
            if keyResult.completion != nil {
                return (lastComma ?? json.index(after: startIndex), "}")
            }
            
            current = skipWhitespace(json, from: keyResult.endIndex)
            if current >= json.endIndex { break }
            
            guard json[current] == ":" else {
                return (lastComma ?? json.index(after: startIndex), nil)
            }
            current = json.index(after: current)
            
            // Parse value
            current = skipWhitespace(json, from: current)
            if current >= json.endIndex { break }
            let valueResult = completeAny(json, from: current, allow: allow)
            if let completion = valueResult.completion {
                return (valueResult.endIndex, completion + "}")
            } else if valueResult.endIndex >= json.endIndex {
                lastComma = nil
            }
            
            current = skipWhitespace(json, from: valueResult.endIndex)
            if current >= json.endIndex {
                break
            }
            
            if json[current] == "," {
                lastComma = current
                current = json.index(after: current)
            }
        }
        
        return allow.contains(.object) ? (lastComma ?? current, "}") : (startIndex, nil)
    }
    
    private func completeNumber(_ json: String, from startIndex: String.Index, allow: Allow) -> (endIndex: String.Index, completion: String?) {
        var current = startIndex
        var modified = false
        
        // Forward scan for digits and number characters
        while current < json.endIndex && "1234567890.-+eE".contains(json[current]) {
            current = json.index(after: current)
        }
        
        // Backward scan to remove incomplete number parts
        while current > startIndex && ".-+eE".contains(json[json.index(before: current)]) {
            modified = true
            current = json.index(before: current)
        }
        
        if modified || current == json.endIndex {
            return allow.contains(.number) ? (current, "") : (startIndex, nil)
        }
        return (current, nil)
    }
    
    private func completeSpecialValue(_ json: String, from startIndex: String.Index, value: String, allow: Allow) -> (endIndex: String.Index, completion: String?) {
        var current = startIndex
        let valueChars = Array(value)
        var i = 0
        
        // Try to match the value
        while current < json.endIndex && i < valueChars.count {
            if json[current] != valueChars[i] {
                break
            }
            current = json.index(after: current)
            i += 1
        }
        
        if i == valueChars.count {
            return (current, nil) // Complete match
        }
        
        // Check if it's a prefix of the value
        if i < valueChars.count && value.hasPrefix(String(json[startIndex..<current])) {
            return (startIndex, value)
        }
        
        return (startIndex, nil)
    }
    
    private func completeAny(_ json: String, from startIndex: String.Index, allow: Allow) -> (endIndex: String.Index, completion: String?) {
        let start = skipWhitespace(json, from: startIndex)
        if start >= json.endIndex {
            return (startIndex, nil)
        }
        
        let char = json[start]
        switch char {
        case "{":
            return completeObject(json, from: start, allow: allow)
        case "[":
            return completeArray(json, from: start, allow: allow)
        case "\"":
            return completeString(json, from: start, allow: allow)
        case "-":
            if start < json.index(before: json.endIndex),
               let next = json.indices.contains(json.index(after: start)) ? json[json.index(after: start)] : nil {
                if next == "I" {
                    return completeSpecialValue(json, from: start, value: "-Infinity", allow: allow)
                }
                return completeNumber(json, from: start, allow: allow)
            }
            return (start, nil)
        case "0"..."9":
            return completeNumber(json, from: start, allow: allow)
        case "t":
            return completeSpecialValue(json, from: start, value: "true", allow: allow)
        case "f":
            return completeSpecialValue(json, from: start, value: "false", allow: allow)
        case "n":
            if allow.contains(.null) {
                return completeSpecialValue(json, from: start, value: "null", allow: allow)
            }
            return (start, nil)
        case "I":
            return completeSpecialValue(json, from: start, value: "Infinity", allow: allow)
        case "N":
            return completeSpecialValue(json, from: start, value: "NaN", allow: allow)
        default:
            return (start, nil)
        }
    }
    
    /// Completes a partial JSON string by adding any missing closing characters
    /// - Parameters:
    ///   - json: The partial JSON string to complete
    ///   - allow: The set of JSON value types allowed in completion, defaults to all types
    /// - Returns: A valid JSON string with all necessary closing characters added
    func complete(json: String, allow: Allow = .all) -> String {
        guard !json.isEmpty else { return "" }
        
        let result = completeAny(json, from: json.startIndex, allow: allow)
        if let completion = result.completion {
            return json[..<result.endIndex] + completion
        }
        return String(json[..<result.endIndex])
    }
}
