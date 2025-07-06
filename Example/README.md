# SheetMusicView Demo App

A comprehensive iOS demo application showcasing the **SheetMusicView** Swift package functionality. This demo serves as both a testing environment for the SheetMusicView package and a reference implementation for developers wanting to integrate the package into their own projects.

## Overview

The SheetMusicView Demo App demonstrates:

- **MusicXML Loading**: Display various types of musical notation from MusicXML files
- **Bundle-based Loading**: Load files from app bundle using the fileName-based API
- **File URL Loading**: **NEW!** Load files from any location using the fileURL-based API with file picker
- **Transposition**: Real-time transposition of music by semitones (-12 to +12)
- **Zoom Controls**: Interactive zoom functionality with slider and button controls
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Responsive Design**: Adaptive layout that works on different screen sizes
- **Sample Music Library**: Built-in collection of sample MusicXML pieces

## Features

### 🎵 Music Display
- High-quality sheet music rendering using OpenSheetMusicDisplay (OSMD)
- Support for complex musical notation including chords, multiple voices, and various time signatures
- Responsive layout that adapts to different screen orientations

### 🎛️ Interactive Controls
- **Transposition Controls**: Transpose music up or down by semitones with visual feedback
- **Zoom Controls**: Zoom from 10% to 500% with slider and preset buttons
- **Music Selection**: Easy-to-use picker for selecting from sample music pieces
- **File Picker**: **NEW!** Native iOS file picker for loading external MusicXML files

### 📱 iOS Integration
- Native SwiftUI interface with iOS design patterns
- Support for both iPhone and iPad
- Proper error handling with native alert dialogs
- Loading states with progress indicators
- **Tab-based Interface**: **NEW!** Two tabs demonstrating different loading approaches

### 📁 Bundle Files Tab
- Demonstrates the traditional fileName-based API
- Loads MusicXML files from the app bundle
- Automatic file discovery and metadata extraction
- Curated sample library with various musical styles

### 📂 File Picker Tab (NEW!)
- Demonstrates the new fileURL-based API
- Native iOS file picker integration
- Support for external files from Documents, iCloud Drive, etc.
- Load user-generated content and files from other apps

## Requirements

- **iOS 15.0+**
- **Xcode 15.0+**
- **Swift 5.7+**

## Getting Started

### 1. Prerequisites

Ensure you have:
- Xcode 15.0 or later installed
- An iOS device or simulator running iOS 15.0 or later
- The SheetMusicView package (located in the parent directory)

### 2. Opening the Project

1. Navigate to the `TestApp` directory
2. Open `SheetMusicDemo.xcodeproj` in Xcode
3. The project is already configured with the SheetMusicView package as a local dependency

### 3. Building and Running

1. Select your target device or simulator
2. Press `Cmd+R` or click the "Run" button in Xcode
3. The app will build and launch on your selected device

## Project Structure

```
TestApp/
├── SheetMusicDemo.xcodeproj/          # Xcode project files
├── SheetMusicDemo/                    # Main app source code
│   ├── SheetMusicDemoApp.swift       # App entry point
│   ├── ContentView.swift             # Main demo interface
│   ├── Views/                        # UI components
│   │   ├── TranspositionControlsView.swift
│   │   ├── ZoomControlsView.swift
│   │   └── MusicPickerView.swift
│   ├── Models/                       # Data models
│   │   └── MusicLibrary.swift
│   ├── Resources/                    # Sample data
│   │   └── SampleMusicXML.swift
│   ├── Assets.xcassets/              # App icons and assets
│   └── Info.plist                   # App configuration
└── README.md                         # This file
```

## Usage Examples

### Basic Integration

The demo shows how to integrate SheetMusicView into your SwiftUI app:

```swift
import SwiftUI
import SheetMusicView

struct ContentView: View {
    @State private var musicXML: String = ""
    @State private var transposeSteps: Int = 0
    @State private var zoomLevel: Double = 1.0
    @State private var isLoading: Bool = false
    
    var body: some View {
        SheetMusicView(
            xml: $musicXML,
            transposeSteps: $transposeSteps,
            isLoading: $isLoading,
            zoomLevel: $zoomLevel,
            onError: { error in
                // Handle errors
                print("Error: \(error.localizedDescription)")
            },
            onReady: {
                // Sheet music is ready
                print("Sheet music loaded successfully!")
            }
        )
    }
}
```

### Error Handling

The demo demonstrates comprehensive error handling:

```swift
SheetMusicView(
    xml: $currentXML,
    transposeSteps: $transposeSteps,
    isLoading: $isLoading,
    onError: { error in
        lastError = error
        showingError = true
    }
)
.alert("Error", isPresented: $showingError) {
    Button("OK") { }
} message: {
    Text(lastError?.localizedDescription ?? "Unknown error occurred")
}
```

## Sample Music Library

The demo includes four sample pieces:

1. **Simple Scale** - Basic C major scale for testing fundamental functionality
2. **Twinkle, Twinkle, Little Star** - Classic melody demonstrating simple notation
3. **Bach Minuet** - More complex classical piece with multiple voices
4. **Chord Progression** - Demonstrates chord notation and harmony display

## Customization

### Adding Your Own Music

To add your own MusicXML files:

1. Add your MusicXML content to `SampleMusicXML.swift`
2. Create a new `MusicPiece` entry in `MusicLibrary.swift`
3. The new piece will automatically appear in the music picker

### Modifying UI Components

The demo's UI is modular and easily customizable:

- **TranspositionControlsView**: Modify transposition UI and behavior
- **ZoomControlsView**: Customize zoom controls and ranges
- **MusicPickerView**: Adjust the music selection interface

## Troubleshooting

### Common Issues

1. **Build Errors**: Ensure the SheetMusicView package path is correct in the project settings
2. **Loading Issues**: Check that MusicXML content is valid and properly formatted
3. **Display Problems**: Verify that the device/simulator supports iOS 15.0+

### Debug Mode

The app includes debug logging. Check the Xcode console for detailed information about:
- Package loading status
- MusicXML parsing results
- JavaScript bridge communication
- Error details

## Integration Guide

To integrate SheetMusicView into your own project:

1. **Add Package Dependency**:
   - In Xcode: File → Add Package Dependencies
   - Enter the SheetMusicView package URL or use local path

2. **Import Framework**:
   ```swift
   import SheetMusicView
   ```

3. **Basic Implementation**:
   ```swift
   SheetMusicView(xml: $musicXML)
   ```

4. **Advanced Features**:
   - Add transposition: `transposeSteps: $transposeSteps`
   - Add zoom control: `zoomLevel: $zoomLevel`
   - Add error handling: `onError: { error in ... }`

## Contributing

This demo app is part of the SheetMusicView package development. To contribute:

1. Test new features using this demo app
2. Report issues with specific reproduction steps
3. Suggest improvements to the demo interface
4. Add new sample music pieces for testing

## License

This demo app is part of the SheetMusicView package and follows the same licensing terms.

---

For more information about the SheetMusicView package, see the main README in the parent directory.
