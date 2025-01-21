import Foundation
import SwiftUI
import Combine

/// Represents a source of content that can be streamed page by page
struct PageSource {
    let content: String
    let length: Int
    var index: String.Index
    
    /// Creates a page source from raw content string
    /// - Parameter content: The string content to stream
    init(content: String) {
        self.content = content
        length = content.count
        index = content.startIndex
    }
    
    /// Creates a page source by loading content from a markdown file in the module bundle
    /// - Parameter name: Name of the markdown file without extension
    /// - Returns: A page source if the file exists and can be loaded, nil otherwise
    init?(name: String) {
        guard let url = Bundle.module.url(forResource: name, withExtension: "md") else { return nil }
        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            content = data
            length = data.count
            index = data.startIndex
        } catch {
            print(error)
            return nil
        }
    }
    
    /// Resets the streaming index back to the start
    mutating func reset() {
        index = content.startIndex
    }
}

/// View model responsible for managing content streaming and playback state
@MainActor
@Observable
final public class AppViewModel {
    private(set) var progress: Double = 0
    var contentLength: Double { Double(source.length) }
    var executedActions: Set<String> = []
    var content = StreamContent()
    var colorScheme: ColorScheme?
    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                if source.index >= source.content.endIndex {
                    reload(length: 0)
                }
                startStreaming()
            } else {
                stopStreaming()
            }
        }
    }
    var chunkSize: Double = 6 // Default chunk size
    var playbackSpeed: Double = 0.1 // Default speed in seconds
    
    private var streamTask: Task<Void, Never>? {
        didSet {
            oldValue?.cancel()
        }
    }
    private var source: PageSource = PageSource(name: "stream") ?? PageSource(content: "")
    private var controllerSubscription: AnyCancellable? {
        didSet {
            oldValue?.cancel()
        }
    }
    private var controller = StreamController() {
        didSet {
            controllerSubscription = controller.output
                .sink { content in
                    self.content = content
                }
        }
    }
    
    /// Creates a new app view model and initializes content streaming
    public init() {
        reload(length: 0)
    }
    
    /// Reloads the content stream from the beginning up to the specified length
    /// - Parameter length: Number of characters to load initially
    func reload(length: Double) {
        isPlaying = false
        progress = length
        content = .init()
        executedActions = []
        source.reset()
        controller = StreamController()
        let data = source.content
        let chunk = String(data.prefix(Int(length)))
        source.index = data.index(data.startIndex, offsetBy: chunk.count)
        controller.processChunk(chunk)
    }
    
    /// Submits the current input values and reloads content accordingly
    func submit() {
        let inputs = content.inputs()
        load(inputs: inputs)
    }
    
    /// Loads content based on provided input values
    /// - Parameter inputs: Dictionary of input values where keys are input names
    func load(inputs: [String: String]) {
        isPlaying = false
        let page = inputs["page"] ?? "stream"
        if let source = PageSource(name: page) {
            self.source = source
        }
        reload(length: 0)
        isPlaying = true
    }
    
    /// Handles input submission and reloads content accordingly
    /// - Parameter input: The input that was submitted
    func inputHandler(_ input: Input) {
        let inputs = content.inputs(submit: input)
        load(inputs: inputs)
    }
    
    var actionHandler: StreamContentActionHandler {
        return .init(
            markAsExecuted: { input in self.executedActions.insert(input.name) },
            canExecute: { input in !self.executedActions.contains(input.name) },
            setColorScheme: { self.colorScheme = $0 }
        )
    }
    
    private func stream() async {
        while source.index < source.content.endIndex, !Task.isCancelled {
            let chunkEndIndex = source.content.index(
                source.index,
                offsetBy: Int(chunkSize),
                limitedBy: source.content.endIndex
            ) ?? source.content.endIndex
            
            let chunk = String(self.source.content[source.index..<chunkEndIndex])
            controller.processChunk(chunk)
            
            source.index = chunkEndIndex
            progress = Double(source.content.distance(from: source.content.startIndex, to: source.index))
            
            if source.index >= self.source.content.endIndex {
                self.isPlaying = false
            }
            
            try? await Task.sleep(for: .milliseconds(Int64(playbackSpeed * 1_000)))
        }
    }
    
    private func startStreaming() {
        streamTask = Task { await stream() }
    }
    
    private func stopStreaming() {
        streamTask?.cancel()
        streamTask = nil
    }
}
