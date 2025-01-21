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

/// A protocol that defines an interface for generating unique identifiers
protocol IdentifierGenerator {
    /// The type used for identifiers, defined as String
    typealias ID = String
    
    /// Generates and returns the next unique identifier
    /// - Returns: A unique identifier string
    mutating func callAsFunction() -> IdentifierGenerator.ID
    
    /// Creates a new nested identifier generator
    /// - Returns: A new IdentifierGenerator instance for generating nested identifiers
    mutating func nested() -> IdentifierGenerator
}

/// An implementation of IdentifierGenerator that generates incremental hierarchical identifiers
struct IncrementalIdentifierGenerator: IdentifierGenerator {
    private var prefix: String
    private var id: Int = 0
    private var nestedId: Int = 0
    typealias ID = String
    
    /// Private initializer that creates a generator with a given prefix
    /// - Parameter prefix: The string prefix to use for generated identifiers
    private init(prefix: String) {
        self.prefix = prefix
    }
    
    /// Creates a new IncrementalIdentifierGenerator instance
    /// - Returns: A new generator instance with an empty prefix
    static func create() -> IncrementalIdentifierGenerator {
        return IncrementalIdentifierGenerator(prefix: "")
    }
    
    /// Generates the next identifier in sequence
    /// - Returns: A unique identifier string
    mutating func callAsFunction() -> ID {
        nestedId = 0
        id += 1
//        print("id = \(prefix)\(id)")
        return "\(prefix)\(id)"
    }
    
    /// Creates a new nested identifier generator
    /// - Returns: A new generator instance for creating hierarchical identifiers
    mutating func nested() -> IdentifierGenerator {
        nestedId += 1
        return Self(prefix: "\(prefix).\(id)-\(nestedId).")
    }
}
