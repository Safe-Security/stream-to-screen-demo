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

/// Extension providing a default configured JSONDecoder instance
extension JSONDecoder {
    /// A pre-configured JSONDecoder instance with ISO8601 date decoding support
    /// 
    /// The decoder is configured with:
    /// - Date format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    /// - Locale: en_US_POSIX
    /// - TimeZone: UTC (GMT+0)
    ///
    /// - Returns: A configured JSONDecoder instance ready for decoding JSON data
    static var `default`: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            return .formatted(dateFormatter)
        }()
        return decoder
    }
}
