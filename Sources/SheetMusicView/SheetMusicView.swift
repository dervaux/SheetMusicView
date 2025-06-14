// SheetMusicView - A SwiftUI bridge for OpenSheetMusicDisplay
//
// This file serves as the main entry point for the SheetMusicView library,
// exporting all public interfaces and types.

import Foundation
import SwiftUI
import WebKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Library Information

/// Information about the SheetMusicView library
public struct SheetMusicViewInfo {
    /// The current version of the SheetMusicView library
    public static let version = "1.0.0"

    /// The version of OpenSheetMusicDisplay that this library is built against
    public static let osmdVersion = "1.9.0"

    /// Supported platforms
    public static let supportedPlatforms = ["iOS 15.0+", "macOS 12.0+"]

    /// Library description
    public static let description = "A comprehensive SwiftUI bridge for OpenSheetMusicDisplay"
}

// MARK: - Main SwiftUI View

/// SwiftUI view wrapper that embeds the OSMD web view for displaying sheet music
public struct SheetMusicView: View {

    // MARK: - Bindings
    @Binding private var xml: String
    @Binding private var transposeSteps: Int
    @Binding private var isLoading: Bool
    @Binding private var zoomLevel: Double?

    // MARK: - State
    @StateObject private var coordinator = SheetMusicCoordinator()

    // MARK: - Callbacks
    private let onError: ((SheetMusicError) -> Void)?
    private let onReady: (() -> Void)?

    // MARK: - Display Options
    private let showTitle: Bool
    private let showInstrumentName: Bool
    private let showComposer: Bool
    private let showDebugPanel: Bool

    // MARK: - Private State
    @State private var lastXML: String = ""
    @State private var lastTransposeSteps: Int = 0
    @State private var lastZoomLevel: Double = 1.0
    @State private var containerSize: CGSize = .zero
    @State private var lastContainerSize: CGSize = .zero
    @State private var lastShowTitle: Bool = false
    @State private var lastShowInstrumentName: Bool = false
    @State private var lastShowComposer: Bool = false
    @State private var lastShowDebugPanel: Bool = false

    // MARK: - Initialization

    /// Initialize SheetMusicView with basic bindings
    public init(
        xml: Binding<String>,
        transposeSteps: Binding<Int> = .constant(0),
        isLoading: Binding<Bool> = .constant(false),
        zoomLevel: Binding<Double>? = nil
    ) {
        self._xml = xml
        self._transposeSteps = transposeSteps
        self._isLoading = isLoading
        if let zoomLevel = zoomLevel {
            self._zoomLevel = Binding(
                get: { zoomLevel.wrappedValue },
                set: { newValue in
                    if let newValue = newValue {
                        zoomLevel.wrappedValue = newValue
                    }
                }
            )
        } else {
            self._zoomLevel = .constant(nil)
        }
        self.onError = nil
        self.onReady = nil
        self.showTitle = false
        self.showInstrumentName = false
        self.showComposer = false
        self.showDebugPanel = false
    }

    /// Initialize SheetMusicView with callbacks
    public init(
        xml: Binding<String>,
        transposeSteps: Binding<Int> = .constant(0),
        isLoading: Binding<Bool> = .constant(false),
        zoomLevel: Binding<Double>? = nil,
        onError: ((SheetMusicError) -> Void)? = nil,
        onReady: (() -> Void)? = nil
    ) {
        self._xml = xml
        self._transposeSteps = transposeSteps
        self._isLoading = isLoading
        if let zoomLevel = zoomLevel {
            self._zoomLevel = Binding(
                get: { zoomLevel.wrappedValue },
                set: { newValue in
                    if let newValue = newValue {
                        zoomLevel.wrappedValue = newValue
                    }
                }
            )
        } else {
            self._zoomLevel = .constant(nil)
        }
        self.onError = onError
        self.onReady = onReady
        self.showTitle = false
        self.showInstrumentName = false
        self.showComposer = false
        self.showDebugPanel = false
    }

    /// Private initializer for view modifiers
    private init(
        xml: Binding<String>,
        transposeSteps: Binding<Int>,
        isLoading: Binding<Bool>,
        zoomLevel: Binding<Double>?,
        onError: ((SheetMusicError) -> Void)?,
        onReady: (() -> Void)?,
        showTitle: Bool,
        showInstrumentName: Bool,
        showComposer: Bool,
        showDebugPanel: Bool
    ) {
        self._xml = xml
        self._transposeSteps = transposeSteps
        self._isLoading = isLoading
        if let zoomLevel = zoomLevel {
            self._zoomLevel = Binding(
                get: { zoomLevel.wrappedValue },
                set: { newValue in
                    if let newValue = newValue {
                        zoomLevel.wrappedValue = newValue
                    }
                }
            )
        } else {
            self._zoomLevel = .constant(nil)
        }
        self.onError = onError
        self.onReady = onReady
        self.showTitle = showTitle
        self.showInstrumentName = showInstrumentName
        self.showComposer = showComposer
        self.showDebugPanel = showDebugPanel
    }

    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            SheetMusicWebViewRepresentable(coordinator: coordinator)
                .onAppear {
                    setupCoordinator()
                    containerSize = geometry.size
                }
                .onChange(of: xml) { newXML in
                    handleXMLChange(newXML)
                }
                .onChange(of: transposeSteps) { newSteps in
                    handleTransposeChange(newSteps)
                }
                .onChange(of: zoomLevel) { newZoom in
                    handleZoomChange(newZoom)
                }
                .onChange(of: coordinator.isLoading) { loading in
                    isLoading = loading
                }
                .onChange(of: geometry.size) { newSize in
                    handleContainerSizeChange(newSize)
                }
                .onAppear {
                    handleDisplayOptionsChange()
                }
                .task(id: "\(showTitle)-\(showInstrumentName)-\(showComposer)-\(showDebugPanel)") {
                    // This task will be cancelled and restarted whenever the display options change
                    // The small delay ensures the view has fully updated before calling the coordinator
                    try? await Task.sleep(nanoseconds: 1_000_000) // 1ms delay
                    handleDisplayOptionsChange(showTitle: showTitle, showInstrumentName: showInstrumentName, showComposer: showComposer, showDebugPanel: showDebugPanel)
                }
        }
    }

    // MARK: - View Modifiers

    /// Controls whether the piece title is displayed
    /// - Parameter show: Whether to show the title (default: true when modifier is used)
    /// - Returns: A modified SheetMusicView instance
    public func showTitle(_ show: Bool = true) -> SheetMusicView {
        // Create a proper zoom binding if we have a non-nil zoom level
        let zoomBinding: Binding<Double>? = _zoomLevel.wrappedValue != nil ?
            Binding<Double>(
                get: { self._zoomLevel.wrappedValue ?? 1.0 },
                set: { newValue in self._zoomLevel.wrappedValue = newValue }
            ) : nil

        return SheetMusicView(
            xml: _xml,
            transposeSteps: _transposeSteps,
            isLoading: _isLoading,
            zoomLevel: zoomBinding,
            onError: onError,
            onReady: onReady,
            showTitle: show,
            showInstrumentName: showInstrumentName,
            showComposer: showComposer,
            showDebugPanel: showDebugPanel
        )
    }

    /// Controls whether instrument names are shown
    /// - Parameter show: Whether to show instrument names (default: true when modifier is used)
    /// - Returns: A modified SheetMusicView instance
    public func showInstrumentName(_ show: Bool = true) -> SheetMusicView {
        // Create a proper zoom binding if we have a non-nil zoom level
        let zoomBinding: Binding<Double>? = _zoomLevel.wrappedValue != nil ?
            Binding<Double>(
                get: { self._zoomLevel.wrappedValue ?? 1.0 },
                set: { newValue in self._zoomLevel.wrappedValue = newValue }
            ) : nil

        return SheetMusicView(
            xml: _xml,
            transposeSteps: _transposeSteps,
            isLoading: _isLoading,
            zoomLevel: zoomBinding,
            onError: onError,
            onReady: onReady,
            showTitle: showTitle,
            showInstrumentName: show,
            showComposer: showComposer,
            showDebugPanel: showDebugPanel
        )
    }

    /// Controls whether the composer name is displayed
    /// - Parameter show: Whether to show the composer (default: true when modifier is used)
    /// - Returns: A modified SheetMusicView instance
    public func showComposer(_ show: Bool = true) -> SheetMusicView {
        // Create a proper zoom binding if we have a non-nil zoom level
        let zoomBinding: Binding<Double>? = _zoomLevel.wrappedValue != nil ?
            Binding<Double>(
                get: { self._zoomLevel.wrappedValue ?? 1.0 },
                set: { newValue in self._zoomLevel.wrappedValue = newValue }
            ) : nil

        return SheetMusicView(
            xml: _xml,
            transposeSteps: _transposeSteps,
            isLoading: _isLoading,
            zoomLevel: zoomBinding,
            onError: onError,
            onReady: onReady,
            showTitle: showTitle,
            showInstrumentName: showInstrumentName,
            showComposer: show,
            showDebugPanel: showDebugPanel
        )
    }

    /// Controls whether the debug status panel is displayed
    /// - Parameter show: Whether to show the debug panel (default: true when modifier is used)
    /// - Returns: A modified SheetMusicView instance
    public func showDebugPanel(_ show: Bool = true) -> SheetMusicView {
        // Create a proper zoom binding if we have a non-nil zoom level
        let zoomBinding: Binding<Double>? = _zoomLevel.wrappedValue != nil ?
            Binding<Double>(
                get: { self._zoomLevel.wrappedValue ?? 1.0 },
                set: { newValue in self._zoomLevel.wrappedValue = newValue }
            ) : nil

        return SheetMusicView(
            xml: _xml,
            transposeSteps: _transposeSteps,
            isLoading: _isLoading,
            zoomLevel: zoomBinding,
            onError: onError,
            onReady: onReady,
            showTitle: showTitle,
            showInstrumentName: showInstrumentName,
            showComposer: showComposer,
            showDebugPanel: show
        )
    }

    // MARK: - Private Methods

    private func setupCoordinator() {
        coordinator.onReady = {
            onReady?()
            // Apply display options when ready
            handleDisplayOptionsChange()
            // Load initial XML if available
            if !xml.isEmpty && xml != lastXML {
                handleXMLChange(xml)
            }
        }

        coordinator.onError = { error in
            onError?(error)
        }
    }

    private func handleXMLChange(_ newXML: String) {
        guard coordinator.isReady, !newXML.isEmpty, newXML != lastXML else { return }

        lastXML = newXML

        Task {
            do {
                try await coordinator.loadMusicXML(newXML)
                try await coordinator.render()

                // Apply current transposition if needed
                if transposeSteps != 0 {
                    lastTransposeSteps = transposeSteps
                    try await coordinator.transpose(transposeSteps)
                } else {
                    lastTransposeSteps = 0
                }

                // Apply current zoom if needed
                if let currentZoom = zoomLevel, currentZoom != 1.0 {
                    lastZoomLevel = currentZoom
                    try await coordinator.setZoom(currentZoom)
                } else {
                    lastZoomLevel = 1.0
                }

                // Apply display options after loading new music
                try await coordinator.updateDisplayOptions(showTitle: showTitle, showInstrumentName: showInstrumentName, showComposer: showComposer)
            } catch {
                // Error handling is done in coordinator
            }
        }
    }

    private func handleTransposeChange(_ newSteps: Int) {
        guard coordinator.isReady, newSteps != lastTransposeSteps else { return }

        lastTransposeSteps = newSteps

        Task {
            do {
                // Send absolute transposition value, not relative
                try await coordinator.transpose(newSteps)
            } catch {
                // Error handling is done in coordinator
            }
        }
    }

    private func handleZoomChange(_ newZoom: Double?) {
        let targetZoom = newZoom ?? 1.0
        guard coordinator.isReady, targetZoom != lastZoomLevel else { return }

        lastZoomLevel = targetZoom

        Task {
            do {
                try await coordinator.setZoom(targetZoom)
            } catch {
                // Error handling is done in coordinator
            }
        }
    }

    private func handleContainerSizeChange(_ newSize: CGSize) {
        // Debounce rapid size changes
        guard abs(newSize.width - lastContainerSize.width) > 1 ||
              abs(newSize.height - lastContainerSize.height) > 1 else { return }

        containerSize = newSize
        lastContainerSize = newSize

        // Only update if OSMD is ready and we have a meaningful size
        guard coordinator.isReady, newSize.width > 0, newSize.height > 0 else { return }

        Task {
            do {
                // Determine optimal page format based on container dimensions
                let pageFormat = determineOptimalPageFormat(for: newSize)

                // Update OSMD with new container size and page format
                try await coordinator.updateContainerSize(width: newSize.width, height: newSize.height)
                try await coordinator.setPageFormat(pageFormat)

                // Re-render to apply the new layout
                try await coordinator.render()
            } catch {
                // Error handling is done in coordinator
            }
        }
    }

    private func handleDisplayOptionsChange() {
        handleDisplayOptionsChange(showTitle: showTitle, showInstrumentName: showInstrumentName, showComposer: showComposer, showDebugPanel: showDebugPanel)
    }

    private func handleDisplayOptionsChange(showTitle: Bool, showInstrumentName: Bool, showComposer: Bool, showDebugPanel: Bool) {
        guard coordinator.isReady else { return }

        // Only update if display options actually changed
        if showTitle != lastShowTitle || showInstrumentName != lastShowInstrumentName || showComposer != lastShowComposer || showDebugPanel != lastShowDebugPanel {
            lastShowTitle = showTitle
            lastShowInstrumentName = showInstrumentName
            lastShowComposer = showComposer
            lastShowDebugPanel = showDebugPanel

            Task {
                do {
                    try await coordinator.updateDisplayOptions(showTitle: showTitle, showInstrumentName: showInstrumentName, showComposer: showComposer)
                    try await coordinator.setDebugPanelVisible(showDebugPanel)
                } catch {
                    #if DEBUG
                    print("SheetMusicView: Failed to update display options: \(error)")
                    #endif
                }
            }
        }
    }

    private func determineOptimalPageFormat(for size: CGSize) -> String {
        let aspectRatio = size.width / size.height

        // For very wide containers (landscape), use endless format for optimal line wrapping
        if aspectRatio > 1.5 {
            return "Endless"
        }
        // For portrait or square containers, use a format that encourages line breaks
        else if aspectRatio < 0.8 {
            return "Endless"
        }
        // For moderate aspect ratios, use endless format as well for best responsiveness
        else {
            return "Endless"
        }
    }
}

// MARK: - WebView Representable

#if os(iOS)
private struct SheetMusicWebViewRepresentable: UIViewRepresentable {
    let coordinator: SheetMusicCoordinator

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true

        let webView = WKWebView(frame: .zero, configuration: configuration)

        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif

        coordinator.setupWebView(webView)

        loadHTML(in: webView)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Updates are handled through the coordinator
    }

    private func loadHTML(in webView: WKWebView) {
        // Try different resource paths
        var htmlURL: URL?

        // First try with subdirectory
        htmlURL = Bundle.module.url(forResource: "osmd", withExtension: "html", subdirectory: "Resources")

        // If not found, try without subdirectory
        if htmlURL == nil {
            htmlURL = Bundle.module.url(forResource: "osmd", withExtension: "html")
        }

        // If still not found, try with different name
        if htmlURL == nil {
            htmlURL = Bundle.module.url(forResource: "osmd", withExtension: "html", subdirectory: "SheetMusicView_SheetMusicView.bundle/Contents/Resources")
        }

        guard let finalURL = htmlURL else {
            print("Error: Could not find osmd.html in bundle")
            print("Bundle path: \(Bundle.module.bundlePath)")
            print("Bundle resources: \(Bundle.module.paths(forResourcesOfType: "html", inDirectory: nil))")
            return
        }

        print("Loading HTML from: \(finalURL.path)")
        webView.loadFileURL(finalURL, allowingReadAccessTo: finalURL.deletingLastPathComponent())
    }
}

#elseif os(macOS)
private struct SheetMusicWebViewRepresentable: NSViewRepresentable {
    let coordinator: SheetMusicCoordinator

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        // Note: javaScriptEnabled is deprecated but still needed for compatibility
        // Modern approach would use WKWebpagePreferences.allowsContentJavaScript per navigation
        configuration.preferences.javaScriptEnabled = true

        let webView = WKWebView(frame: .zero, configuration: configuration)

        #if DEBUG
        if #available(macOS 13.3, *) {
            webView.isInspectable = true
        }
        #endif

        coordinator.setupWebView(webView)

        loadHTML(in: webView)

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // Updates are handled through the coordinator
    }

    private func loadHTML(in webView: WKWebView) {
        // Try different resource paths
        var htmlURL: URL?

        // First try with subdirectory
        htmlURL = Bundle.module.url(forResource: "osmd", withExtension: "html", subdirectory: "Resources")

        // If not found, try without subdirectory
        if htmlURL == nil {
            htmlURL = Bundle.module.url(forResource: "osmd", withExtension: "html")
        }

        // If still not found, try with different name
        if htmlURL == nil {
            htmlURL = Bundle.module.url(forResource: "osmd", withExtension: "html", subdirectory: "SheetMusicView_SheetMusicView.bundle/Contents/Resources")
        }

        guard let finalURL = htmlURL else {
            print("Error: Could not find osmd.html in bundle")
            print("Bundle path: \(Bundle.module.bundlePath)")
            print("Bundle resources: \(Bundle.module.paths(forResourcesOfType: "html", inDirectory: nil))")
            return
        }

        print("Loading HTML from: \(finalURL.path)")
        webView.loadFileURL(finalURL, allowingReadAccessTo: finalURL.deletingLastPathComponent())
    }
}
#endif

// MARK: - Preview
#if DEBUG
struct SheetMusicView_Previews: PreviewProvider {
    @State static var xml = ""
    @State static var transposeSteps = 0
    @State static var isLoading = false

    static var previews: some View {
        SheetMusicView(
            xml: $xml,
            transposeSteps: $transposeSteps,
            isLoading: $isLoading
        )
        .frame(height: 400)
        .padding()
    }
}
#endif
