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

/// A wrapper type that makes any Error conform to Identifiable and Equatable protocols
/// by assigning it a unique identifier. This allows errors to be used in SwiftUI views
/// and collections that require unique identification.
struct IdentifiableError: Identifiable, Equatable, Sendable {
    /// Unique identifier for the error instance
    var id: IdentifierGenerator.ID
    /// The original error being wrapped
    var underlyingError: Error
    
    /// Creates a new identifiable error wrapper
    /// - Parameters:
    ///   - ids: Generator for creating unique identifiers
    ///   - underlyingError: The original error to wrap
    init(ids: inout IdentifierGenerator, underlyingError: Error) {
        self.id = ids()
        self.underlyingError = underlyingError
    }
    
    /// Compares two identifiable errors for equality based on their unique identifiers
    /// - Parameters:
    ///   - lhs: First error to compare
    ///   - rhs: Second error to compare
    /// - Returns: True if the errors have the same identifier
    static func ==(lhs: IdentifiableError, rhs: IdentifiableError) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Hashes the error's identifier into the hasher
    /// - Parameter hasher: The hasher to use
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
