import XCTest
@testable import SwiftUIOSMD

final class SwiftUIOSMDTests: XCTestCase {
    
    func testOSMDErrorDescriptions() {
        let errors: [OSMDError] = [
            .notReady,
            .webViewNotAvailable,
            .webViewLoadingFailed("Test error"),
            .javascriptEvaluationFailed("JS error"),
            .javascriptError("Runtime error"),
            .loadingFailed("Load error"),
            .renderingFailed("Render error"),
            .transpositionFailed("Transpose error"),
            .operationFailed("Operation error")
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    @MainActor
    func testOSMDCoordinatorInitialization() {
        let coordinator = OSMDCoordinator()

        XCTAssertFalse(coordinator.isLoading)
        XCTAssertFalse(coordinator.isReady)
        XCTAssertNil(coordinator.lastError)
    }
    
    func testOSMDCoordinatorNotReadyOperations() async {
        let coordinator = await OSMDCoordinator()
        
        // Test operations when not ready
        do {
            try await coordinator.loadMusicXML("<musicxml></musicxml>")
            XCTFail("Should throw notReady error")
        } catch OSMDError.notReady {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            try await coordinator.transpose(2)
            XCTFail("Should throw notReady error")
        } catch OSMDError.notReady {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            try await coordinator.render()
            XCTFail("Should throw notReady error")
        } catch OSMDError.notReady {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            try await coordinator.clear()
            XCTFail("Should throw notReady error")
        } catch OSMDError.notReady {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
