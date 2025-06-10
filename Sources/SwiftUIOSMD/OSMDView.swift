import SwiftUI
import WebKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// SwiftUI view wrapper that embeds the OSMD web view
public struct OSMDView: View {
    
    // MARK: - Bindings
    @Binding private var xml: String
    @Binding private var transposeSteps: Int
    @Binding private var isLoading: Bool
    
    // MARK: - State
    @StateObject private var coordinator = OSMDCoordinator()
    
    // MARK: - Callbacks
    private let onError: ((OSMDError) -> Void)?
    private let onReady: (() -> Void)?
    
    // MARK: - Private State
    @State private var lastXML: String = ""
    @State private var lastTransposeSteps: Int = 0
    
    // MARK: - Initialization
    
    /// Initialize OSMDView with basic bindings
    public init(
        xml: Binding<String>,
        transposeSteps: Binding<Int> = .constant(0),
        isLoading: Binding<Bool> = .constant(false)
    ) {
        self._xml = xml
        self._transposeSteps = transposeSteps
        self._isLoading = isLoading
        self.onError = nil
        self.onReady = nil
    }
    
    /// Initialize OSMDView with callbacks
    public init(
        xml: Binding<String>,
        transposeSteps: Binding<Int> = .constant(0),
        isLoading: Binding<Bool> = .constant(false),
        onError: ((OSMDError) -> Void)? = nil,
        onReady: (() -> Void)? = nil
    ) {
        self._xml = xml
        self._transposeSteps = transposeSteps
        self._isLoading = isLoading
        self.onError = onError
        self.onReady = onReady
    }
    
    // MARK: - Body
    public var body: some View {
        OSMDWebViewRepresentable(coordinator: coordinator)
            .onAppear {
                setupCoordinator()
            }
            .onChange(of: xml) { newXML in
                handleXMLChange(newXML)
            }
            .onChange(of: transposeSteps) { newSteps in
                handleTransposeChange(newSteps)
            }
            .onChange(of: coordinator.isLoading) { loading in
                isLoading = loading
            }
    }
    
    // MARK: - Private Methods
    
    private func setupCoordinator() {
        coordinator.onReady = {
            onReady?()
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
}

// MARK: - WebView Representable

#if os(iOS)
private struct OSMDWebViewRepresentable: UIViewRepresentable {
    let coordinator: OSMDCoordinator
    
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
            htmlURL = Bundle.module.url(forResource: "osmd", withExtension: "html", subdirectory: "SwiftUIOSMD_SwiftUIOSMD.bundle/Contents/Resources")
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
private struct OSMDWebViewRepresentable: NSViewRepresentable {
    let coordinator: OSMDCoordinator
    
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
            htmlURL = Bundle.module.url(forResource: "osmd", withExtension: "html", subdirectory: "SwiftUIOSMD_SwiftUIOSMD.bundle/Contents/Resources")
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
struct OSMDView_Previews: PreviewProvider {
    @State static var xml = ""
    @State static var transposeSteps = 0
    @State static var isLoading = false
    
    static var previews: some View {
        OSMDView(
            xml: $xml,
            transposeSteps: $transposeSteps,
            isLoading: $isLoading
        )
        .frame(height: 400)
        .padding()
    }
}
#endif
