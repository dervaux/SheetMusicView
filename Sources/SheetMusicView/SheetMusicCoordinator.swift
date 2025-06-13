import Foundation
import WebKit

/// Coordinator class that manages the communication bridge between Swift and the OSMD JavaScript engine
@MainActor
public class SheetMusicCoordinator: NSObject, ObservableObject {

    // MARK: - Published Properties
    @Published public var isLoading: Bool = false
    @Published public var lastError: SheetMusicError?
    @Published public var isReady: Bool = false

    // MARK: - Private Properties
    private weak var webView: WKWebView?
    private var pendingOperations: [String: (Result<Any?, SheetMusicError>) -> Void] = [:]
    private var operationCounter: Int = 0
    private var currentTransposition: Int = 0
    private var currentZoom: Double = 1.0

    // MARK: - Callbacks
    public var onReady: (() -> Void)?
    public var onError: ((SheetMusicError) -> Void)?
    
    // MARK: - Initialization
    public override init() {
        super.init()
    }
    
    // MARK: - WebView Setup
    public func setupWebView(_ webView: WKWebView) {
        self.webView = webView
        webView.configuration.userContentController.add(self, name: "osmdBridge")
        webView.navigationDelegate = self

        #if DEBUG
        print("SheetMusicCoordinator: WebView setup complete")
        #endif
    }
    
    // MARK: - OSMD Operations
    
    /// Load MusicXML content into OSMD
    public func loadMusicXML(_ xml: String) async throws {
        guard isReady else {
            throw SheetMusicError.notReady
        }

        isLoading = true
        lastError = nil

        do {
            let escapedXML = xml.replacingOccurrences(of: "\\", with: "\\\\")
                               .replacingOccurrences(of: "\"", with: "\\\"")
                               .replacingOccurrences(of: "\n", with: "\\n")
                               .replacingOccurrences(of: "\r", with: "\\r")

            let script = "osmdLoadXML(\"\(escapedXML)\")"
            _ = try await evaluateJavaScript(script)

            // Reset transposition and zoom when loading new music
            currentTransposition = 0
            currentZoom = 1.0
            isLoading = false
        } catch {
            isLoading = false
            let sheetMusicError = error as? SheetMusicError ?? SheetMusicError.loadingFailed(error.localizedDescription)
            lastError = sheetMusicError
            onError?(sheetMusicError)
            throw sheetMusicError
        }
    }
    
    /// Transpose the music by the specified number of semitones
    public func transpose(_ steps: Int) async throws {
        guard isReady else {
            throw SheetMusicError.notReady
        }

        do {
            // Set the absolute transposition value
            currentTransposition = steps
            let script = "osmdSetTranspose(\(steps))"
            _ = try await evaluateJavaScript(script)
        } catch {
            let sheetMusicError = error as? SheetMusicError ?? SheetMusicError.transpositionFailed(error.localizedDescription)
            lastError = sheetMusicError
            onError?(sheetMusicError)
            throw sheetMusicError
        }
    }
    
    /// Render the loaded music
    public func render() async throws {
        guard isReady else {
            throw SheetMusicError.notReady
        }

        do {
            let script = "osmdRender()"
            _ = try await evaluateJavaScript(script)
        } catch {
            let sheetMusicError = error as? SheetMusicError ?? SheetMusicError.renderingFailed(error.localizedDescription)
            lastError = sheetMusicError
            onError?(sheetMusicError)
            throw sheetMusicError
        }
    }

    /// Set the zoom level for the music display
    public func setZoom(_ level: Double) async throws {
        guard isReady else {
            throw SheetMusicError.notReady
        }

        // Validate zoom level (typical range is 0.1 to 5.0)
        guard level >= 0.1 && level <= 5.0 else {
            throw SheetMusicError.invalidZoomLevel(level)
        }

        do {
            currentZoom = level
            let script = "osmdSetZoom(\(level))"
            _ = try await evaluateJavaScript(script)
        } catch {
            let sheetMusicError = error as? SheetMusicError ?? SheetMusicError.zoomFailed(error.localizedDescription)
            lastError = sheetMusicError
            onError?(sheetMusicError)
            throw sheetMusicError
        }
    }

    /// Zoom in by increasing the zoom level by 0.02
    public func zoomIn() async throws {
        let newZoom = min(currentZoom + 0.02, 5.0)
        try await setZoom(newZoom)
    }

    /// Zoom out by decreasing the zoom level by 0.02
    public func zoomOut() async throws {
        let newZoom = max(currentZoom - 0.02, 0.1)
        try await setZoom(newZoom)
    }

    /// Reset zoom to default level (1.0)
    public func resetZoom() async throws {
        try await setZoom(1.0)
    }

    /// Get the current zoom level
    public var zoomLevel: Double {
        return currentZoom
    }

    /// Clear the current music display
    public func clear() async throws {
        guard isReady else {
            throw SheetMusicError.notReady
        }

        do {
            let script = "osmdClear()"
            _ = try await evaluateJavaScript(script)
        } catch {
            let sheetMusicError = error as? SheetMusicError ?? SheetMusicError.operationFailed(error.localizedDescription)
            lastError = sheetMusicError
            onError?(sheetMusicError)
            throw sheetMusicError
        }
    }

    /// Update the container size for responsive layout
    public func updateContainerSize(width: CGFloat, height: CGFloat) async throws {
        guard isReady else {
            throw SheetMusicError.notReady
        }

        do {
            let script = "osmdUpdateContainerSize(\(width), \(height))"
            _ = try await evaluateJavaScript(script)
        } catch {
            let sheetMusicError = error as? SheetMusicError ?? SheetMusicError.operationFailed(error.localizedDescription)
            lastError = sheetMusicError
            onError?(sheetMusicError)
            throw sheetMusicError
        }
    }

    /// Set page format for responsive layout
    public func setPageFormat(_ format: String) async throws {
        guard isReady else {
            throw SheetMusicError.notReady
        }

        do {
            let script = "osmdSetPageFormat('\(format)')"
            _ = try await evaluateJavaScript(script)
        } catch {
            let sheetMusicError = error as? SheetMusicError ?? SheetMusicError.operationFailed(error.localizedDescription)
            lastError = sheetMusicError
            onError?(sheetMusicError)
            throw sheetMusicError
        }
    }
    
    // MARK: - Private Methods
    
    private func evaluateJavaScript(_ script: String) async throws -> Any? {
        guard let webView = webView else {
            throw SheetMusicError.webViewNotAvailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            let operationId = "op_\(operationCounter)"
            operationCounter += 1

            pendingOperations[operationId] = { result in
                continuation.resume(with: result)
            }

            let wrappedScript = """
                try {
                    const result = \(script);
                    window.webkit.messageHandlers.osmdBridge.postMessage({
                        type: 'success',
                        operationId: '\(operationId)',
                        result: result
                    });
                } catch (error) {
                    window.webkit.messageHandlers.osmdBridge.postMessage({
                        type: 'error',
                        operationId: '\(operationId)',
                        error: error.message || error.toString()
                    });
                }
            """

            webView.evaluateJavaScript(wrappedScript) { _, error in
                if let error = error {
                    // Only resume if the operation is still pending
                    if self.pendingOperations.removeValue(forKey: operationId) != nil {
                        continuation.resume(throwing: SheetMusicError.javascriptEvaluationFailed(error.localizedDescription))
                    }
                }
                // If no error, the success/error will be handled by the message handler
            }

            // Add a timeout to prevent hanging
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if self.pendingOperations.removeValue(forKey: operationId) != nil {
                    continuation.resume(throwing: SheetMusicError.operationFailed("Operation timed out"))
                }
            }
        }
    }
}

// MARK: - WKScriptMessageHandler
extension SheetMusicCoordinator: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else {
            #if DEBUG
            print("SheetMusicCoordinator: Received invalid message body")
            #endif
            return
        }

        #if DEBUG
        print("SheetMusicCoordinator: Received message: \(body)")
        #endif

        if let type = body["type"] as? String {
            switch type {
            case "test":
                #if DEBUG
                if let message = body["message"] as? String {
                    print("SheetMusicCoordinator: Test message received: \(message)")
                }
                #endif

            case "ready":
                #if DEBUG
                print("SheetMusicCoordinator: OSMD is ready!")
                #endif
                isReady = true
                onReady?()

            case "success":
                if let operationId = body["operationId"] as? String,
                   let completion = pendingOperations.removeValue(forKey: operationId) {
                    completion(.success(body["result"]))
                }

            case "error":
                if let operationId = body["operationId"] as? String,
                   let completion = pendingOperations.removeValue(forKey: operationId) {
                    let errorMessage = body["error"] as? String ?? "Unknown error"
                    completion(.failure(SheetMusicError.javascriptError(errorMessage)))
                } else if let errorMessage = body["error"] as? String {
                    let error = SheetMusicError.javascriptError(errorMessage)
                    lastError = error
                    onError?(error)
                }

            default:
                break
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension SheetMusicCoordinator: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        #if DEBUG
        print("SheetMusicCoordinator: WebView finished loading")
        #endif
        // Web view finished loading, OSMD initialization will be handled by JavaScript
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        #if DEBUG
        print("SheetMusicCoordinator: WebView failed to load: \(error.localizedDescription)")
        #endif
        let sheetMusicError = SheetMusicError.webViewLoadingFailed(error.localizedDescription)
        lastError = sheetMusicError
        onError?(sheetMusicError)
    }
}

// MARK: - Error Types
public enum SheetMusicError: Error, LocalizedError {
    case notReady
    case webViewNotAvailable
    case webViewLoadingFailed(String)
    case javascriptEvaluationFailed(String)
    case javascriptError(String)
    case loadingFailed(String)
    case renderingFailed(String)
    case transpositionFailed(String)
    case zoomFailed(String)
    case invalidZoomLevel(Double)
    case operationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .notReady:
            return "Sheet music display is not ready. Please wait for initialization to complete."
        case .webViewNotAvailable:
            return "WebView is not available."
        case .webViewLoadingFailed(let message):
            return "WebView loading failed: \(message)"
        case .javascriptEvaluationFailed(let message):
            return "JavaScript evaluation failed: \(message)"
        case .javascriptError(let message):
            return "JavaScript error: \(message)"
        case .loadingFailed(let message):
            return "Music loading failed: \(message)"
        case .renderingFailed(let message):
            return "Music rendering failed: \(message)"
        case .transpositionFailed(let message):
            return "Transposition failed: \(message)"
        case .zoomFailed(let message):
            return "Zoom operation failed: \(message)"
        case .invalidZoomLevel(let level):
            return "Invalid zoom level: \(level). Zoom level must be between 0.1 and 5.0."
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        }
    }
}
