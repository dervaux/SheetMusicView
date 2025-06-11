# SwiftUI-OSMD Bridge

A comprehensive SwiftUI bridge for [OpenSheetMusicDisplay (OSMD)](https://opensheetmusicdisplay.org) that enables native iOS and macOS applications to display and interact with music notation seamlessly.

> **📋 Documentation Policy**: This README contains a complete API reference section that MUST be updated whenever new functionality is added. See the [Complete API Reference](#complete-api-reference) section for all available methods, properties, and features.

## Table of Contents

- [Project Overview](#project-overview)
- [Swift Package Manager Integration](#swift-package-manager-integration)
- [**Complete API Reference**](#complete-api-reference) ← **All available functionality**
- [Usage Examples](#usage-examples)
- [Development Notes](#development-notes)

## Project Overview

This project provides a native SwiftUI wrapper around the powerful OpenSheetMusicDisplay JavaScript library, allowing developers to integrate professional music notation rendering into their iOS and macOS applications. The bridge leverages a hybrid architecture using `WKWebView` to embed OSMD's full JavaScript functionality within clean, reactive SwiftUI components.

### Key Features

- **Native SwiftUI Integration**: Clean, declarative API that follows SwiftUI patterns and conventions
- **Full OSMD Functionality**: Access to all OpenSheetMusicDisplay features including rendering, transposition, playback control, and more
- **Responsive Line Wrapping**: Automatic line breaks that adapt to container size changes, device rotation, and window resizing
- **Dynamic Layout**: Real-time responsive behavior for optimal music display across different screen sizes and orientations
- **Hybrid Architecture**: Combines the power of OSMD's mature JavaScript engine with native iOS performance
- **Reactive Data Binding**: Uses SwiftUI's `@Binding` and `@State` for seamless data flow
- **Cross-Platform**: Supports both iOS and macOS applications
- **Type-Safe API**: Swift-native interfaces with proper error handling and async support

## Technical Architecture

### Core Components

The bridge consists of two primary components that work together to provide seamless OSMD integration:

#### OSMDCoordinator
A coordinator class that manages the communication bridge between Swift and the OSMD JavaScript engine:
- Handles JavaScript evaluation and message passing
- Manages OSMD lifecycle and state
- Provides error handling and async operation support
- Implements the full OSMD API surface in Swift

#### OSMDView
A SwiftUI view wrapper that embeds the OSMD web view:
- Implements `UIViewRepresentable` for iOS and `NSViewRepresentable` for macOS
- Manages WebKit view lifecycle
- Provides reactive updates through SwiftUI's binding system
- Handles view configuration and resource loading

### Communication Flow

```
SwiftUI App ←→ OSMDView ←→ OSMDCoordinator ←→ WKWebView ←→ OSMD JavaScript
```

The bridge uses `WKWebView`'s JavaScript evaluation capabilities for Swift-to-OSMD communication and `WKScriptMessageHandler` for bidirectional messaging, ensuring robust and performant interaction between the native Swift layer and the embedded OSMD engine.

### Offline Capability

This project includes the compiled OpenSheetMusicDisplay library (v1.9.0) directly in the package resources. This ensures:
- Complete offline functionality without internet dependencies
- Faster loading times by avoiding CDN requests
- Consistent library version across all installations
- Reliable operation in environments with restricted network access

## Swift Package Manager Integration

The SwiftUI-OSMD bridge is designed for seamless integration into iOS and macOS projects using Swift Package Manager. Follow these comprehensive steps to add it to your project.

### Repository and Package Names

- **GitHub Repository**: `https://github.com/dervaux/SwiftUIOSMD`
- **Swift Package Name**: `SwiftUIOSMD`
- **Import Statement**: `import SwiftUIOSMD`

The repository and Swift package now have consistent naming for clarity and ease of use.

### System Requirements

- **iOS**: 15.0+
- **macOS**: 12.0+
- **Xcode**: 13.0+
- **Swift**: 5.7+

### Method 1: Integration via Xcode (Recommended)

This is the easiest method for most developers:

1. **Open your Xcode project**

2. **Add Package Dependency**:
   - Go to `File` → `Add Package Dependencies...`
   - Enter the repository URL: `https://github.com/dervaux/SwiftUIOSMD.git`
   - Click `Add Package`

3. **Configure Package Options**:
   - **Dependency Rule**: Choose "Up to Next Major Version" and enter `1.0.0`
   - **Add to Target**: Select your app target
   - Click `Add Package`

4. **Verify Installation**:
   - In your project navigator, you should see `SwiftUIOSMD` under "Package Dependencies"
   - The package will be automatically linked to your target

### Method 2: Package.swift Integration

For Swift Package projects or manual configuration:

```swift
// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/dervaux/SwiftUIOSMD.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "SwiftUIOSMD", package: "SwiftUIOSMD")
            ]
        )
    ]
)
```

### Method 3: Local Development Integration

For local development or when working with the source code directly:

```swift
// Package.swift
dependencies: [
    .package(path: "../SwiftUIOSMD")  // Adjust path as needed
]
```

### Import and Basic Usage

After successful integration, import the library in your Swift files:

```swift
import SwiftUI
import SwiftUIOSMD

struct ContentView: View {
    @State private var musicXML: String = ""
    @State private var transposeSteps: Int = 0
    @State private var isLoading: Bool = false

    var body: some View {
        OSMDView(
            xml: $musicXML,
            transposeSteps: $transposeSteps,
            isLoading: $isLoading
        )
        .frame(height: 400)
    }
}
```

### Verification Steps

To verify the integration was successful:

1. **Build your project** (`Cmd+B`) - it should compile without errors
2. **Check imports** - `import SwiftUIOSMD` should not show any errors
3. **Test basic functionality** - Try creating an `OSMDView` in a preview or simulator

### App Configuration

#### Info.plist Requirements

No special Info.plist configuration is required for basic functionality. The package handles all necessary WebKit permissions internally.

#### Optional: Network Security (if loading remote MusicXML)

If your app loads MusicXML files from remote servers, you may need to configure App Transport Security:

```xml
<!-- Only add this if you need to load MusicXML from HTTP (not HTTPS) sources -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Troubleshooting

#### Common Integration Issues

**Problem**: "No such module 'SwiftUIOSMD'"
- **Solution**: Ensure the package was added correctly and your target includes the dependency
- **Check**: Project Navigator → Package Dependencies → SwiftUIOSMD should be visible

**Problem**: Build errors related to minimum deployment target
- **Solution**: Ensure your app's deployment target is iOS 15.0+ or macOS 12.0+
- **Check**: Project Settings → Deployment Info → Deployment Target

**Problem**: Package resolution fails
- **Solution**: Check your internet connection and GitHub repository access
- **Alternative**: Use local development integration method

**Problem**: WebView not displaying content
- **Solution**: Ensure you're testing on a physical device or simulator (not SwiftUI previews for complex WebKit content)
- **Check**: Add some sample MusicXML content to verify the view is working

#### Getting Help

If you encounter issues:
1. Check the [Issues](https://github.com/dervaux/SwiftUIOSMD/issues) page
2. Review the example projects in `TestApp/` and `ResponsiveDemo/` directories
3. Ensure you're using compatible versions of Xcode and Swift

### Quick Start Summary

For experienced developers, here's the fastest way to get started:

1. **Add Package**: In Xcode, `File` → `Add Package Dependencies` → `https://github.com/dervaux/SwiftUIOSMD.git`
2. **Import**: Add `import SwiftUIOSMD` to your Swift file
3. **Use**: Create an `OSMDView(xml: $musicXML, transposeSteps: $transposeSteps, isLoading: $isLoading)`
4. **Test**: Load some MusicXML content and verify rendering

That's it! The package handles all the complex WebKit and OSMD integration automatically.

## Complete API Reference

> **⚠️ IMPORTANT**: This section documents ALL available functionality in SwiftUIOSMD. When new features are implemented, they MUST be documented here immediately. This ensures users always have access to the complete, up-to-date API reference.

### Core Components

#### OSMDView (SwiftUI View)

The main SwiftUI component for displaying music notation.

**Initializers:**
```swift
// Basic initialization
OSMDView(
    xml: Binding<String>,
    transposeSteps: Binding<Int> = .constant(0),
    isLoading: Binding<Bool> = .constant(false)
)

// Full initialization with callbacks
OSMDView(
    xml: Binding<String>,
    transposeSteps: Binding<Int> = .constant(0),
    isLoading: Binding<Bool> = .constant(false),
    onError: ((OSMDError) -> Void)? = nil,
    onReady: (() -> Void)? = nil
)
```

**Parameters:**
- `xml: Binding<String>` - MusicXML content to display
- `transposeSteps: Binding<Int>` - Number of semitones to transpose (-12 to +12)
- `isLoading: Binding<Bool>` - Loading state indicator
- `onError: ((OSMDError) -> Void)?` - Error callback handler
- `onReady: (() -> Void)?` - Ready state callback

#### OSMDCoordinator (JavaScript Bridge)

Low-level coordinator for direct OSMD control.

**Published Properties:**
```swift
@Published public var isLoading: Bool        // Current loading state
@Published public var lastError: OSMDError?  // Last error encountered
@Published public var isReady: Bool          // OSMD initialization state
```

**Callback Properties:**
```swift
public var onReady: (() -> Void)?           // Called when OSMD is ready
public var onError: ((OSMDError) -> Void)?  // Called on errors
```

**Methods:**
```swift
// Load MusicXML content
func loadMusicXML(_ xml: String) async throws

// Transpose music by semitones
func transpose(_ steps: Int) async throws

// Render the loaded music
func render() async throws

// Clear the current display
func clear() async throws

// Update container size for responsive layout
func updateContainerSize(width: CGFloat, height: CGFloat) async throws

// Set page format (e.g., "A4", "Letter", "Endless")
func setPageFormat(_ format: String) async throws
```

#### OSMDError (Error Handling)

Comprehensive error types for all OSMD operations.

**Error Cases:**
```swift
case notReady                              // OSMD not initialized
case webViewNotAvailable                   // WebView not accessible
case webViewLoadingFailed(String)          // WebView failed to load
case javascriptEvaluationFailed(String)    // JS evaluation error
case javascriptError(String)               // JS runtime error
case loadingFailed(String)                 // MusicXML loading error
case renderingFailed(String)               // Rendering error
case transpositionFailed(String)           // Transposition error
case operationFailed(String)               // General operation error
```

**Error Descriptions:**
All errors conform to `LocalizedError` and provide descriptive error messages.

#### SwiftUIOSMDInfo (Library Information)

Static information about the library.

**Properties:**
```swift
public static let version: String              // "1.0.0"
public static let osmdVersion: String          // "1.9.0"
public static let supportedPlatforms: [String] // ["iOS 15.0+", "macOS 12.0+"]
public static let description: String          // Library description
```

### Current Implementation Status

✅ **Fully Implemented Features:**

**Core Rendering:**
- MusicXML loading and parsing
- Sheet music rendering and display
- Responsive layout and scaling
- Automatic line wrapping and page breaks
- Offline operation (no CDN dependencies)

**Music Manipulation:**
- Absolute transposition (chromatic, -12 to +12 semitones)
- Real-time transposition updates
- Transposition state management

**Responsive Features:**
- Container size monitoring with GeometryReader
- Dynamic page format adjustment
- Device rotation and window resize handling
- Debounced performance optimization
- Scrollable content for long musical pieces

**Error Handling:**
- Comprehensive error types
- Async/await error propagation
- User-friendly error messages
- Error recovery mechanisms

**Platform Support:**
- iOS 15.0+ with UIKit integration
- macOS 12.0+ with AppKit integration
- SwiftUI reactive bindings
- WebKit debugging support

### Planned Features (Roadmap)

🚧 **Next Implementation Priority:**
- Playback control and cursor tracking
- Interactive note selection and editing
- Custom styling and theming options
- Export functionality (PNG, SVG, PDF)
- Advanced layout configuration
- Plugin system integration
- Real-time collaboration features
- MIDI input/output support

### API Extension Guidelines

When implementing new features, follow these requirements:

1. **Add to OSMDCoordinator**: Implement the JavaScript bridge method
2. **Update OSMDView**: Add SwiftUI bindings if needed
3. **Document in README**: Update this API reference section immediately
4. **Add Error Handling**: Include appropriate OSMDError cases
5. **Write Tests**: Add unit tests for new functionality
6. **Update Examples**: Show usage in example applications

**Example of proper API extension:**
```swift
// 1. Add to OSMDCoordinator
public func setTempo(_ bpm: Int) async throws {
    // Implementation
}

// 2. Add to OSMDView if needed
@Binding private var tempo: Int

// 3. Document here in README (this section)
// 4. Add OSMDError.tempoChangeFailed if needed
// 5. Add tests in SwiftUIOSMDTests
// 6. Update TestApp example
```

This ensures the API reference remains complete and accurate for all users.

## Responsive Line Wrapping

The SwiftUI-OSMD bridge includes comprehensive responsive line wrapping functionality that automatically adapts music notation layout to different screen sizes and orientations.

### Key Features

- **Automatic Line Breaks**: Music notation automatically wraps to the next line when it extends beyond the available container width
- **Device Rotation Support**: Line wrapping adjusts seamlessly when rotating between portrait and landscape orientations
- **Window Resize Handling**: On macOS and iPad, line wrapping responds dynamically to window size changes
- **Performance Optimized**: Debounced resize events ensure smooth performance during rapid size changes
- **Container Size Monitoring**: Uses SwiftUI's `GeometryReader` to detect and respond to container size changes

### How It Works

1. **Container Monitoring**: The `OSMDView` uses `GeometryReader` to monitor container size changes
2. **Intelligent Updates**: Only meaningful size changes (>1px) trigger layout updates to optimize performance
3. **Dynamic Page Format**: Automatically selects optimal page format based on container dimensions and aspect ratio
4. **OSMD Integration**: Leverages OSMD's built-in `autoResize` and "Endless" page format for optimal line wrapping
5. **Debounced Rendering**: Resize events are debounced with a 150ms delay for smooth performance

### Testing Responsive Behavior

A comprehensive demo is available in the `ResponsiveDemo/` directory that showcases:
- Real-time container size information
- Interactive window resizing (macOS)
- Device rotation testing (iOS)
- Transposition with responsive layout
- Performance monitoring

To run the responsive demo:
```bash
cd ResponsiveDemo
swift run ResponsiveDemo
```

## Usage Examples

### Basic Implementation

```swift
import SwiftUI
import SwiftUIOSMD

struct ContentView: View {
    @State private var musicXML: String = ""
    @State private var transposeSteps: Int = 0
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            OSMDView(
                xml: $musicXML,
                transposeSteps: $transposeSteps,
                isLoading: $isLoading
            )
            .frame(height: 400)

            HStack {
                Button("Load Sample") {
                    loadSampleMusic()
                }

                Stepper("Transpose: \(transposeSteps)",
                       value: $transposeSteps,
                       in: -12...12)
            }
            .padding()
        }
    }

    private func loadSampleMusic() {
        // Load MusicXML from bundle or network
        if let path = Bundle.main.path(forResource: "sample", ofType: "xml"),
           let xml = try? String(contentsOfFile: path) {
            musicXML = xml
        }
    }
}
```

### Advanced Usage with Error Handling

```swift
struct AdvancedOSMDView: View {
    @StateObject private var osmdManager = OSMDManager()

    var body: some View {
        VStack {
            if osmdManager.isLoading {
                ProgressView("Loading music...")
            } else {
                OSMDView(
                    xml: $osmdManager.currentXML,
                    transposeSteps: $osmdManager.transposeSteps,
                    onError: { error in
                        osmdManager.handleError(error)
                    },
                    onReady: {
                        osmdManager.onOSMDReady()
                    }
                )
            }

            if let error = osmdManager.lastError {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

class OSMDManager: ObservableObject {
    @Published var currentXML: String = ""
    @Published var transposeSteps: Int = 0
    @Published var isLoading: Bool = false
    @Published var lastError: Error?

    func handleError(_ error: Error) {
        lastError = error
        isLoading = false
    }

    func onOSMDReady() {
        isLoading = false
        lastError = nil
    }
}
```

## Development Notes

### Project Structure

```
SwiftUIOSMD/
├── Sources/
│   └── SwiftUIOSMD/
│       ├── OSMDView.swift
│       ├── OSMDCoordinator.swift
│       └── Resources/
│           ├── osmd.html
│           └── opensheetmusicdisplay.min.js
├── Tests/
├── Package.swift
└── README.md
```

### Repository Setup (For Package Publishers)

If you're setting up this package for distribution:

1. **Create a GitHub repository** for your fork/distribution
2. **Update the repository URL** in the README examples above
3. **Tag releases** using semantic versioning:
   ```bash
   git tag 1.0.0
   git push origin 1.0.0
   ```
4. **Verify package resolution** by testing integration in a sample project

### Building and Testing

1. **Clone the repository**:
   ```bash
   git clone https://github.com/dervaux/SwiftUIOSMD.git
   cd SwiftUIOSMD
   ```

2. **Build the package**:
   ```bash
   swift build
   ```

3. **Open in Xcode**:
   ```bash
   open Package.swift
   ```

4. **Run tests**:
   ```bash
   swift test
   ```

5. **Test example applications**:
   ```bash
   # Test the basic example
   cd TestApp
   swift run OSMDTestApp

   # Test responsive features
   cd ../ResponsiveDemo
   swift run ResponsiveDemo
   ```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for details.

The included OpenSheetMusicDisplay library is also licensed under BSD-3-Clause. The compiled library file (`opensheetmusicdisplay.min.js`) included in this package is from the official OpenSheetMusicDisplay project.

## Acknowledgments

- [OpenSheetMusicDisplay](https://opensheetmusicdisplay.org) team for the excellent music notation engine
- [VexFlow](https://vexflow.com) for the underlying music rendering technology
- The Swift and SwiftUI communities for inspiration and best practicesw