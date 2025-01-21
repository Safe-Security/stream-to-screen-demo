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

extension Array {
    public subscript(safe index: Int) -> Element? {
        // Safely lookup an index that might be out of bounds
        // returning nil if it does not exist
        get {
            indices.contains(index) ? self[index] : nil
        }
        // Safely set value at an index that might be out of bounds
        // do nothing if value is `nil`
        set {
            guard indices.contains(index), let newValue else { return }
            self[index] = newValue
        }
    }
}

