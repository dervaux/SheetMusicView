import Foundation
import WebKit

/// Coordinator class that manages the communication bridge between Swift and the OSMD JavaScript engine
@MainActor
public class OSMDCoordinator: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isLoading: Bool = false
    @Published public var lastError: OSMDError?
    @Published public var isReady: Bool = false
    
    // MARK: - Private Properties
    private weak var webView: WKWebView?
    private var pendingOperations: [String: (Result<Any?, OSMDError>) -> Void] = [:]
    private var operationCounter: Int = 0
    private var currentTransposition: Int = 0
    
    // MARK: - Callbacks
    public var onReady: (() -> Void)?
    public var onError: ((OSMDError) -> Void)?
    
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
        print("OSMDCoordinator: WebView setup complete")
        #endif
    }
    
    // MARK: - OSMD Operations
    
    /// Load MusicXML content into OSMD
    public func loadMusicXML(_ xml: String) async throws {
        guard isReady else {
            throw OSMDError.notReady
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

            // Reset transposition when loading new music
            currentTransposition = 0
            isLoading = false
        } catch {
            isLoading = false
            let osmdError = error as? OSMDError ?? OSMDError.loadingFailed(error.localizedDescription)
            lastError = osmdError
            onError?(osmdError)
            throw osmdError
        }
    }
    
    /// Transpose the music by the specified number of semitones
    public func transpose(_ steps: Int) async throws {
        guard isReady else {
            throw OSMDError.notReady
        }

        do {
            // Set the absolute transposition value
            currentTransposition = steps
            let script = "osmdSetTranspose(\(steps))"
            _ = try await evaluateJavaScript(script)
        } catch {
            let osmdError = error as? OSMDError ?? OSMDError.transpositionFailed(error.localizedDescription)
            lastError = osmdError
            onError?(osmdError)
            throw osmdError
        }
    }
    
    /// Render the loaded music
    public func render() async throws {
        guard isReady else {
            throw OSMDError.notReady
        }
        
        do {
            let script = "osmdRender()"
            _ = try await evaluateJavaScript(script)
        } catch {
            let osmdError = error as? OSMDError ?? OSMDError.renderingFailed(error.localizedDescription)
            lastError = osmdError
            onError?(osmdError)
            throw osmdError
        }
    }
    
    /// Clear the current music display
    public func clear() async throws {
        guard isReady else {
            throw OSMDError.notReady
        }
        
        do {
            let script = "osmdClear()"
            _ = try await evaluateJavaScript(script)
        } catch {
            let osmdError = error as? OSMDError ?? OSMDError.operationFailed(error.localizedDescription)
            lastError = osmdError
            onError?(osmdError)
            throw osmdError
        }
    }
    
    // MARK: - Private Methods
    
    private func evaluateJavaScript(_ script: String) async throws -> Any? {
        guard let webView = webView else {
            throw OSMDError.webViewNotAvailable
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
                        continuation.resume(throwing: OSMDError.javascriptEvaluationFailed(error.localizedDescription))
                    }
                }
                // If no error, the success/error will be handled by the message handler
            }

            // Add a timeout to prevent hanging
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if self.pendingOperations.removeValue(forKey: operationId) != nil {
                    continuation.resume(throwing: OSMDError.operationFailed("Operation timed out"))
                }
            }
        }
    }
}

// MARK: - WKScriptMessageHandler
extension OSMDCoordinator: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else {
            #if DEBUG
            print("OSMDCoordinator: Received invalid message body")
            #endif
            return
        }

        #if DEBUG
        print("OSMDCoordinator: Received message: \(body)")
        #endif

        if let type = body["type"] as? String {
            switch type {
            case "test":
                #if DEBUG
                if let message = body["message"] as? String {
                    print("OSMDCoordinator: Test message received: \(message)")
                }
                #endif

            case "ready":
                #if DEBUG
                print("OSMDCoordinator: OSMD is ready!")
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
                    completion(.failure(OSMDError.javascriptError(errorMessage)))
                } else if let errorMessage = body["error"] as? String {
                    let error = OSMDError.javascriptError(errorMessage)
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
extension OSMDCoordinator: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        #if DEBUG
        print("OSMDCoordinator: WebView finished loading")
        #endif
        // Web view finished loading, OSMD initialization will be handled by JavaScript
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        #if DEBUG
        print("OSMDCoordinator: WebView failed to load: \(error.localizedDescription)")
        #endif
        let osmdError = OSMDError.webViewLoadingFailed(error.localizedDescription)
        lastError = osmdError
        onError?(osmdError)
    }
}

// MARK: - Error Types
public enum OSMDError: Error, LocalizedError {
    case notReady
    case webViewNotAvailable
    case webViewLoadingFailed(String)
    case javascriptEvaluationFailed(String)
    case javascriptError(String)
    case loadingFailed(String)
    case renderingFailed(String)
    case transpositionFailed(String)
    case operationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .notReady:
            return "OSMD is not ready. Please wait for initialization to complete."
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
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        }
    }
}
