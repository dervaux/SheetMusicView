# SwiftUI-OSMD Bridge

A comprehensive SwiftUI bridge for [OpenSheetMusicDisplay (OSMD)](https://opensheetmusicdisplay.org) that enables native iOS and macOS applications to display and interact with music notation seamlessly.

## Project Overview

This project provides a native SwiftUI wrapper around the powerful OpenSheetMusicDisplay JavaScript library, allowing developers to integrate professional music notation rendering into their iOS and macOS applications. The bridge leverages a hybrid architecture using `WKWebView` to embed OSMD's full JavaScript functionality within clean, reactive SwiftUI components.

### Key Features

- **Native SwiftUI Integration**: Clean, declarative API that follows SwiftUI patterns and conventions
- **Full OSMD Functionality**: Access to all OpenSheetMusicDisplay features including rendering, transposition, playback control, and more
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

### Reference Implementation

This project includes the complete OpenSheetMusicDisplay library (v1.9.0) in the `OSMD_do_not_touch/` directory as a reference implementation. This ensures:
- Development environment consistency
- API compatibility verification
- Local testing and debugging capabilities
- Independence from external CDN dependencies

## Swift Package Manager Integration

### Adding as a Dependency

Add the SwiftUI-OSMD bridge to your project using Swift Package Manager:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftUI-OSMD-Bridge.git", from: "1.0.0")
]
```

### Target Configuration

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "SwiftUIOSMD", package: "SwiftUI-OSMD-Bridge")
    ]
)
```

### Requirements

- **iOS**: 14.0+
- **macOS**: 11.0+
- **Xcode**: 12.0+
- **Swift**: 5.3+

### Required Capabilities

Ensure your app's `Info.plist` includes:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

## API Coverage and Extensibility

### Current Implementation Status

The bridge is designed to provide complete coverage of OSMD's functionality. The initial implementation includes:

✅ **Core Rendering**
- MusicXML loading and parsing
- Sheet music rendering and display
- Responsive layout and scaling

✅ **Music Manipulation**
- Transposition (chromatic and diatonic)
- Key signature changes
- Tempo modifications

🚧 **Planned Features** (Full OSMD API Coverage)
- Playback control and cursor tracking
- Interactive note selection and editing
- Custom styling and theming
- Export functionality (PNG, SVG, PDF)
- Advanced layout options
- Plugin system integration
- Real-time collaboration features

### Extensibility

The bridge architecture is designed for easy extension. New OSMD features can be added by:

1. Extending the `OSMDCoordinator` with new JavaScript bridge methods
2. Adding corresponding Swift API methods
3. Updating the SwiftUI binding system as needed

All OSMD functions will be exposed through type-safe Swift interfaces with proper error handling and documentation.

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
SwiftUI-OSMD-Bridge/
├── Sources/
│   └── SwiftUIOSMD/
│       ├── OSMDView.swift
│       ├── OSMDCoordinator.swift
│       └── Resources/
│           └── osmd.html
├── OSMD_do_not_touch/          # Reference OSMD implementation
├── Tests/
├── Package.swift
└── README.md
```

### Building and Testing

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/SwiftUI-OSMD-Bridge.git
   cd SwiftUI-OSMD-Bridge
   ```

2. **Build the OSMD reference** (for development):
   ```bash
   cd OSMD_do_not_touch
   npm install
   npm run build
   ```

3. **Open in Xcode**:
   ```bash
   open Package.swift
   ```

4. **Run tests**:
   ```bash
   swift test
   ```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for details.

The included OpenSheetMusicDisplay library is also licensed under BSD-3-Clause - see [OSMD_do_not_touch/LICENSE](OSMD_do_not_touch/LICENSE) for details.

## Acknowledgments

- [OpenSheetMusicDisplay](https://opensheetmusicdisplay.org) team for the excellent music notation engine
- [VexFlow](https://vexflow.com) for the underlying music rendering technology
- The Swift and SwiftUI communities for inspiration and best practices

---

For questions, issues, or contributions, please visit our [GitHub repository](https://github.com/yourusername/SwiftUI-OSMD-Bridge).
