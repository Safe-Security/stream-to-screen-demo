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
import Combine

/// Controller responsible for processing streaming content and publishing parsed results
/// 
/// Handles buffering of incoming content chunks, parsing them into structured `StreamContent`,
/// and publishing the results while managing error notifications.
@MainActor
final class StreamController {
    /// Publisher that emits parsed `StreamContent` from the input stream
    ///
    /// The output is throttled and processed asynchronously to optimize performance.
    /// Any parsing errors are collected and logged through the error notification system.
    lazy var output: some Publisher<StreamContent, Never> = {
        $input
            .throttle(for: .milliseconds(8), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.global())
            .map { buffer in
                let content = StreamContentBuilder(buffer: buffer).build()
                return content
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { (content: StreamContent) in
                for error in content.errors {
                    self.notifyError(error)
                }
            })
            .share()
    }()
    
    private var notifiedErrors: Set<IdentifiableError.ID> = []
    
    @Published private var input: String = ""
    
    /// Processes a new chunk of content by appending it to the input buffer
    /// - Parameter chunk: The new content chunk to process
    func processChunk(_ chunk: String) {
        input += chunk
    }
    
    private func notifyError(_ error: IdentifiableError) {
        guard !notifiedErrors.insert(error.id).inserted else { return }
        
        print("Stream parsing error: \(String(reflecting: error.underlyingError))")
    }
}
