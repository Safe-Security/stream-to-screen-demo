# Stream To Screen

A demo SwiftUI project showcasing how to handle rich GenAI responses in a native iOS application. This project accompanies the article [From Stream to Screen: Handling GenAI Rich Responses in SwiftUI](https://medium.com/safe-engineering/from-stream-to-screen-handling-genai-rich-responses-in-swiftui-da138acfaa05).

## Overview

Project demonstrates how to parse and display streaming responses from GenAI backends that contain rich content like markdown, widgets, and interactive elements. The project implements a flexible architecture for handling different types of content in real-time.

## Project Structure

```
StreamToScreen/
├── App/
│   └── Sources/
│       └── App/
│           ├── Views/
│           │   ├── Widgets/          # UI components for different widget types
│           │   └── Inputs/           # Input-related view components
│           ├── Model/
│           │   ├── Raw/              # Raw data parsing
│           │   ├── Widgets/          # Widget-specific models and builders
│           │   ├── Form/             # Form handling
│           │   ├── StreamController.swift    # Main stream handling logic
│           │   ├── StreamContentBuilder.swift # Content parsing and construction
│           │   └── StreamContent.swift       # Content model definitions
│           └── Resources/
├── swift-markdown-ui-main/           # Markdown rendering dependency
└── StreamToScreen.xcodeproj/         # Xcode project file
```

## Features

- Real-time parsing of streaming content
- Support for various UI types
- Markdown rendering
- Interactive form elements
- Error handling and recovery

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 6.0+

## Getting Started

1. Clone the repository
2. Open `StreamToScreen.xcodeproj` in Xcode
3. Build and run the project

## Implementation Details

The project follows a modular architecture with clear separation of concerns:

- `StreamController`: Manages the streaming content and state
- `StreamContentBuilder`: Handles content parsing and widget construction
- Widget System: Extensible architecture for different content types
- SwiftUI Views: Declarative UI components for each widget type

## License

See [LICENSE.md](LICENSE.md) for more details.
