# Responsive Line Wrapping Demo

This demo showcases the automatic line wrapping functionality implemented in the SheetMusicView bridge project.

## Features Demonstrated

### 1. **Automatic Line Breaks**
- Music notation automatically wraps to the next line when it extends beyond the available width
- No horizontal scrolling required
- Optimal use of available screen space

### 2. **Responsive Behavior**
- **Device Rotation**: Line wrapping adjusts when rotating between portrait and landscape
- **Window Resizing**: On macOS and iPad, line wrapping responds to window size changes
- **Dynamic Layout**: Container size changes trigger automatic re-layout

### 3. **Performance Optimization**
- **Debounced Updates**: Rapid size changes are debounced for smooth performance
- **Intelligent Triggering**: Only meaningful size changes trigger re-rendering
- **Efficient Re-layout**: OSMD's built-in responsive capabilities are leveraged

## How to Run

### Prerequisites
- Xcode 15.0 or later
- iOS 14.0+ / macOS 11.0+ target
- Internet connection (for OSMD CDN)

### Running the Demo

1. **From Terminal:**
   ```bash
   cd ResponsiveDemo
   swift run ResponsiveDemo
   ```

2. **From Xcode:**
   - Open `ResponsiveDemo/Package.swift` in Xcode
   - Select your target device/simulator
   - Press Cmd+R to run

## Testing Responsive Behavior

### 1. **Load Sample Music**
- Click "Load Sample Music" to load a multi-measure piece
- Observe how the music is initially laid out

### 2. **Test Window Resizing (macOS)**
- Drag the window corners to resize
- Watch how the music automatically reflows to fit the new width
- Try both narrow and wide window configurations

### 3. **Test Device Rotation (iOS)**
- Rotate your device between portrait and landscape
- Observe how the line breaks adjust automatically
- Notice the improved layout in landscape mode

### 4. **Test Transposition**
- Use the transpose controls to change the key
- Verify that responsive behavior works with transposed music
- Test extreme transposition values

## Implementation Details

### Key Components

1. **Enhanced SheetMusicView**
   - Uses `GeometryReader` to monitor container size changes
   - Implements debounced size change detection
   - Automatically determines optimal page format

2. **Extended SheetMusicCoordinator**
   - New `updateContainerSize()` method
   - New `setPageFormat()` method
   - Seamless integration with existing functionality

3. **Improved JavaScript Bridge**
   - Enhanced OSMD configuration for responsiveness
   - Debounced window resize handling
   - Dynamic container size updates

### Configuration Options

The implementation uses OSMD's "Endless" page format by default, which provides:
- Automatic line wrapping based on container width
- No fixed page boundaries
- Optimal responsive behavior across different screen sizes

### Performance Considerations

- **Debouncing**: Size changes are debounced with a 150ms delay
- **Threshold Detection**: Only size changes > 1px trigger updates
- **Efficient Rendering**: Leverages OSMD's built-in autoResize capability

## Troubleshooting

### Common Issues

1. **Music Not Loading**
   - Ensure internet connection for OSMD CDN
   - Check browser console for JavaScript errors

2. **Responsive Behavior Not Working**
   - Verify that autoResize is enabled in OSMD configuration
   - Check that container size changes are being detected

3. **Performance Issues**
   - Increase debounce delay if needed
   - Verify that only necessary re-renders are triggered

### Debug Information

The demo displays real-time container information including:
- Current container dimensions
- Aspect ratio
- Orientation (Portrait/Landscape)

## Integration with Your App

To add responsive line wrapping to your own SwiftUI app:

```swift
import SheetMusicView

struct MyMusicView: View {
    @State private var musicXML: String = "..."
    @State private var transposeSteps: Int = 0
    @State private var isLoading: Bool = false

    var body: some View {
        SheetMusicView(
            xml: $musicXML,
            transposeSteps: $transposeSteps,
            isLoading: $isLoading
        )
        .frame(minHeight: 400) // Set minimum height as needed
    }
}
```

The responsive behavior is automatically enabled and requires no additional configuration.

## Next Steps

- Test with more complex musical pieces
- Experiment with different page formats
- Customize responsive thresholds for your use case
- Integrate with your app's specific layout requirements
