// SwiftUIOSMD - A SwiftUI bridge for OpenSheetMusicDisplay
//
// This file serves as the main entry point for the SwiftUIOSMD library,
// exporting all public interfaces and types.

import Foundation

// MARK: - Public Exports

// The main components are already public in their respective files:
// - OSMDView: SwiftUI view component
// - OSMDCoordinator: JavaScript bridge coordinator
// - OSMDError: Error types for the library

// MARK: - Library Information

/// Information about the SwiftUIOSMD library
public struct SwiftUIOSMDInfo {
    /// The current version of the SwiftUIOSMD library
    public static let version = "1.0.0"
    
    /// The version of OpenSheetMusicDisplay that this library is built against
    public static let osmdVersion = "1.9.0"
    
    /// Supported platforms
    public static let supportedPlatforms = ["iOS 14.0+", "macOS 11.0+"]
    
    /// Library description
    public static let description = "A comprehensive SwiftUI bridge for OpenSheetMusicDisplay"
}
