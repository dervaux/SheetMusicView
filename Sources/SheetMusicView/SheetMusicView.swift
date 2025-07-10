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
    @State private var loadedXML: String = ""
    @State private var loadedFileName: String = ""

    // MARK: - File Loading Properties
    private let fileName: String?
    private let bundle: Bundle
    private let fileURL: URL?

    // MARK: - Callbacks
    private let onError: ((SheetMusicError) -> Void)?
    private let onReady: (() -> Void)?

    // MARK: - Display Options
    private let showTitle: Bool
    private let showInstrumentName: Bool
    private let showComposer: Bool
    private let showDebugPanel: Bool

    // MARK: - Page Margins
    private let pageLeftMargin: Double
    private let pageRightMargin: Double

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
    @State private var lastPageLeftMargin: Double = 10.0
    @State private var lastPageRightMargin: Double = 10.0

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
        self.fileName = nil
        self.bundle = Bundle.main
        self.fileURL = nil
        self.onError = nil
        self.onReady = nil
        self.showTitle = false
        self.showInstrumentName = false
        self.showComposer = false
        self.showDebugPanel = false
        self.pageLeftMargin = 10.0
        self.pageRightMargin = 10.0
    }

    /// Initialize SheetMusicView with a filename (without .musicxml extension)
    public init(
        fileName: String,
        transposeSteps: Binding<Int> = .constant(0),
        isLoading: Binding<Bool> = .constant(false),
        zoomLevel: Binding<Double>? = nil,
        bundle: Bundle = Bundle.main
    ) {
        self._xml = .constant("")
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
        self.fileName = fileName
        self.bundle = bundle
        self.fileURL = nil
        self.onError = nil
        self.onReady = nil
        self.showTitle = false
        self.showInstrumentName = false
        self.showComposer = false
        self.showDebugPanel = false
        self.pageLeftMargin = 10.0
        self.pageRightMargin = 10.0
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
        self.fileName = nil
        self.bundle = Bundle.main
        self.fileURL = nil
        self.onError = onError
        self.onReady = onReady
        self.showTitle = false
        self.showInstrumentName = false
        self.showComposer = false
        self.showDebugPanel = false
        self.pageLeftMargin = 10.0
        self.pageRightMargin = 10.0
    }

    /// Initialize SheetMusicView with filename and callbacks
    public init(
        fileName: String,
        transposeSteps: Binding<Int> = .constant(0),
        isLoading: Binding<Bool> = .constant(false),
        zoomLevel: Binding<Double>? = nil,
        bundle: Bundle = Bundle.main,
        onError: ((SheetMusicError) -> Void)? = nil,
        onReady: (() -> Void)? = nil
    ) {
        self._xml = .constant("")
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
        self.fileName = fileName
        self.bundle = bundle
        self.fileURL = nil
        self.onError = onError
        self.onReady = onReady
        self.showTitle = false
        self.showInstrumentName = false
        self.showComposer = false
        self.showDebugPanel = false
        self.pageLeftMargin = 10.0
        self.pageRightMargin = 10.0
    }

    /// Initialize SheetMusicView with a file URL
    public init(
        fileURL: URL,
        transposeSteps: Binding<Int> = .constant(0),
        isLoading: Binding<Bool> = .constant(false),
        zoomLevel: Binding<Double>? = nil,
        onError: ((SheetMusicError) -> Void)? = nil,
        onReady: (() -> Void)? = nil
    ) {
        self._xml = .constant("")
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
        self.fileName = nil
        self.bundle = Bundle.main
        self.onError = onError
        self.onReady = onReady
        self.showTitle = false
        self.showInstrumentName = false
        self.showComposer = false
        self.showDebugPanel = false
        self.pageLeftMargin = 10.0
        self.pageRightMargin = 10.0

        // Store the file URL for loading
        self.fileURL = fileURL
    }

    /// Private initializer for view modifiers
    private init(
        xml: Binding<String>,
        transposeSteps: Binding<Int>,
        isLoading: Binding<Bool>,
        zoomLevel: Binding<Double>?,
        fileName: String?,
        bundle: Bundle,
        fileURL: URL?,
        onError: ((SheetMusicError) -> Void)?,
        onReady: (() -> Void)?,
        showTitle: Bool,
        showInstrumentName: Bool,
        showComposer: Bool,
        showDebugPanel: Bool,
        pageLeftMargin: Double,
        pageRightMargin: Double
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
        self.fileName = fileName
        self.bundle = bundle
        self.fileURL = fileURL
        self.onError = onError
        self.onReady = onReady
        self.showTitle = showTitle
        self.showInstrumentName = showInstrumentName
        self.showComposer = showComposer
        self.showDebugPanel = showDebugPanel
        self.pageLeftMargin = pageLeftMargin
        self.pageRightMargin = pageRightMargin
    }

    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            SheetMusicWebViewRepresentable(coordinator: coordinator)
                .onAppear {
                    setupCoordinator()
                    containerSize = geometry.size
                    handleDisplayOptionsChange()
                    // Load file when view appears (handles initial load and view recreation with new fileName)
                    loadFileIfNeeded()
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
                .task(id: "\(showTitle)-\(showInstrumentName)-\(showComposer)-\(showDebugPanel)") {
                    // This task will be cancelled and restarted whenever the display options change
                    // The small delay ensures the view has fully updated before calling the coordinator
                    try? await Task.sleep(nanoseconds: 1_000_000) // 1ms delay
                    handleDisplayOptionsChange(showTitle: showTitle, showInstrumentName: showInstrumentName, showComposer: showComposer, showDebugPanel: showDebugPanel)
                }
                .task(id: "\(pageLeftMargin)-\(pageRightMargin)") {
                    // This task will be cancelled and restarted whenever the page margins change
                    // The small delay ensures the view has fully updated before calling the coordinator
                    try? await Task.sleep(nanoseconds: 1_000_000) // 1ms delay
                    handlePageMarginsChange(left: pageLeftMargin, right: pageRightMargin)
                }
                .task(id: fileName) {
                    // This task will be cancelled and restarted whenever the fileName changes
                    // This handles the case where the view is recreated with a new fileName
                    if let fileName = fileName, !fileName.isEmpty {
                        loadFileIfNeeded()
                    }
                }
                .task(id: fileURL?.absoluteString) {
                    // This task will be cancelled and restarted whenever the fileURL changes
                    // This handles the case where the view is recreated with a new fileURL
                    if fileURL != nil {
                        loadFileIfNeeded()
                    }
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
            fileName: fileName,
            bundle: bundle,
            fileURL: fileURL,
            onError: onError,
            onReady: onReady,
            showTitle: show,
            showInstrumentName: showInstrumentName,
            showComposer: showComposer,
            showDebugPanel: showDebugPanel,
            pageLeftMargin: pageLeftMargin,
            pageRightMargin: pageRightMargin
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
            fileName: fileName,
            bundle: bundle,
            fileURL: fileURL,
            onError: onError,
            onReady: onReady,
            showTitle: showTitle,
            showInstrumentName: show,
            showComposer: showComposer,
            showDebugPanel: showDebugPanel,
            pageLeftMargin: pageLeftMargin,
            pageRightMargin: pageRightMargin
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
            fileName: fileName,
            bundle: bundle,
            fileURL: fileURL,
            onError: onError,
            onReady: onReady,
            showTitle: showTitle,
            showInstrumentName: showInstrumentName,
            showComposer: show,
            showDebugPanel: showDebugPanel,
            pageLeftMargin: pageLeftMargin,
            pageRightMargin: pageRightMargin
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
            fileName: fileName,
            bundle: bundle,
            fileURL: fileURL,
            onError: onError,
            onReady: onReady,
            showTitle: showTitle,
            showInstrumentName: showInstrumentName,
            showComposer: showComposer,
            showDebugPanel: show,
            pageLeftMargin: pageLeftMargin,
            pageRightMargin: pageRightMargin
        )
    }

    /// Controls the page margins for the sheet music display
    /// - Parameters:
    ///   - left: Left page margin in units (default: 10.0)
    ///   - right: Right page margin in units (default: 10.0)
    /// - Returns: A modified SheetMusicView instance
    public func pageMargins(left: Double = 10.0, right: Double = 10.0) -> SheetMusicView {
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
            fileName: fileName,
            bundle: bundle,
            fileURL: fileURL,
            onError: onError,
            onReady: onReady,
            showTitle: showTitle,
            showInstrumentName: showInstrumentName,
            showComposer: showComposer,
            showDebugPanel: showDebugPanel,
            pageLeftMargin: left,
            pageRightMargin: right
        )
    }

    // MARK: - Private Methods

    private func setupCoordinator() {
        coordinator.onReady = {
            onReady?()
            // Apply display options when ready
            handleDisplayOptionsChange()
            // Apply page margins when ready
            handlePageMarginsChange(left: pageLeftMargin, right: pageRightMargin)
            // Load initial XML if available (for xml-based API)
            if !xml.isEmpty && xml != lastXML {
                handleXMLChange(xml)
            }
            // For fileName-based API, check if we have loaded content or need to load
            else if let fileName = fileName, !fileName.isEmpty {
                if !loadedXML.isEmpty {
                    print("SheetMusicView: Coordinator ready, loading previously loaded XML for '\(fileName)'")
                    handleXMLChange(loadedXML)
                } else {
                    print("SheetMusicView: Coordinator ready, loading file '\(fileName)'")
                    loadFileIfNeeded()
                }
            }
            // For fileURL-based API, check if we have loaded content or need to load
            else if let fileURL = fileURL {
                if !loadedXML.isEmpty {
                    print("SheetMusicView: Coordinator ready, loading previously loaded XML for '\(fileURL.lastPathComponent)'")
                    handleXMLChange(loadedXML)
                } else {
                    print("SheetMusicView: Coordinator ready, loading file '\(fileURL.lastPathComponent)'")
                    loadFileIfNeeded()
                }
            }
        }

        coordinator.onError = { error in
            onError?(error)
        }
    }

    private func loadFileIfNeeded() {
        print("SheetMusicView: loadFileIfNeeded called - fileName: \(fileName ?? "nil"), fileURL: \(fileURL?.lastPathComponent ?? "nil"), loadedFileName: \(loadedFileName)")

        // Handle fileName-based loading
        if let fileName = fileName, !fileName.isEmpty {
            // Check if we need to load a different file
            guard fileName != loadedFileName else {
                print("SheetMusicView: File '\(fileName)' already loaded, skipping")
                return
            }

            print("SheetMusicView: Starting to load file '\(fileName).musicxml'")

            Task {
                do {
                    let xmlContent = try await loadMusicXMLFile(fileName: fileName, from: bundle)
                    loadedXML = xmlContent
                    loadedFileName = fileName

                    print("SheetMusicView: Successfully loaded file '\(fileName).musicxml', content length: \(xmlContent.count)")

                    // Load the XML content regardless of coordinator state
                    // handleXMLChange will check if coordinator is ready
                    handleXMLChange(xmlContent)
                } catch {
                    print("SheetMusicView: Failed to load file '\(fileName).musicxml': \(error.localizedDescription)")
                    let sheetMusicError = SheetMusicError.loadingFailed("Failed to load file '\(fileName).musicxml': \(error.localizedDescription)")
                    onError?(sheetMusicError)
                }
            }
        }
        // Handle fileURL-based loading
        else if let fileURL = fileURL {
            let urlString = fileURL.absoluteString

            // Check if we need to load a different file
            guard urlString != loadedFileName else {
                print("SheetMusicView: File '\(fileURL.lastPathComponent)' already loaded, skipping")
                return
            }

            print("SheetMusicView: Starting to load file from URL: \(fileURL.lastPathComponent)")

            Task {
                do {
                    let xmlContent = try await loadMusicXMLFile(from: fileURL)
                    loadedXML = xmlContent
                    loadedFileName = urlString

                    print("SheetMusicView: Successfully loaded file '\(fileURL.lastPathComponent)', content length: \(xmlContent.count)")

                    // Load the XML content regardless of coordinator state
                    // handleXMLChange will check if coordinator is ready
                    handleXMLChange(xmlContent)
                } catch {
                    print("SheetMusicView: Failed to load file '\(fileURL.lastPathComponent)': \(error.localizedDescription)")
                    let sheetMusicError = SheetMusicError.loadingFailed("Failed to load file '\(fileURL.lastPathComponent)': \(error.localizedDescription)")
                    onError?(sheetMusicError)
                }
            }
        }
        else {
            print("SheetMusicView: No fileName or fileURL provided, clearing loadedFileName")
            loadedFileName = ""
        }
    }

    private func loadMusicXMLFile(fileName: String, from bundle: Bundle) async throws -> String {
        // Try different possible file extensions and locations
        let possibleExtensions = ["musicxml", "xml"]
        let possibleSubdirectories = [nil, "Resources", "MusicXML"]

        for subdirectory in possibleSubdirectories {
            for ext in possibleExtensions {
                if let url = bundle.url(forResource: fileName, withExtension: ext, subdirectory: subdirectory) {
                    // For local bundle files, we can still use String(contentsOf:) since they're local
                    return try String(contentsOf: url, encoding: .utf8)
                }
            }
        }

        // If not found in bundle, throw an error with helpful information
        throw NSError(
            domain: "SheetMusicView",
            code: 404,
            userInfo: [
                NSLocalizedDescriptionKey: "Could not find '\(fileName).musicxml' or '\(fileName).xml' in bundle",
                NSLocalizedRecoverySuggestionErrorKey: "Make sure the file is added to your app bundle. Tried extensions: \(possibleExtensions.joined(separator: ", "))"
            ]
        )
    }

    private func loadMusicXMLFile(from url: URL) async throws -> String {
        // Check if this is a local file URL or a remote URL
        if url.isFileURL {
            // For local files, use synchronous loading since it's fast
            return try String(contentsOf: url, encoding: .utf8)
        } else {
            // For remote URLs, use async URLSession to avoid blocking the main thread
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let content = String(data: data, encoding: .utf8) else {
                throw NSError(
                    domain: "SheetMusicView",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode XML content from URL: \(url.absoluteString)"]
                )
            }
            return content
        }
    }

    private func handleXMLChange(_ newXML: String) {
        guard coordinator.isReady, !newXML.isEmpty, newXML != lastXML else {
            print("SheetMusicView: handleXMLChange early return - coordinator.isReady: \(coordinator.isReady), newXML.isEmpty: \(newXML.isEmpty), newXML == lastXML: \(newXML == lastXML)")
            return
        }

        lastXML = newXML
        print("SheetMusicView: handleXMLChange proceeding to load XML")

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

    private func handlePageMarginsChange(left: Double, right: Double) {
        guard coordinator.isReady else { return }

        // Only update if page margins actually changed
        if left != lastPageLeftMargin || right != lastPageRightMargin {
            lastPageLeftMargin = left
            lastPageRightMargin = right

            Task {
                do {
                    try await coordinator.setPageMargins(left: left, right: right)
                } catch {
                    #if DEBUG
                    print("SheetMusicView: Failed to update page margins: \(error)")
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
