import XCTest
@testable import SheetMusicView

final class SheetMusicViewTests: XCTestCase {

    func testSheetMusicErrorDescriptions() {
        let errors: [SheetMusicError] = [
            .notReady,
            .webViewNotAvailable,
            .webViewLoadingFailed("Test error"),
            .javascriptEvaluationFailed("JS error"),
            .javascriptError("Runtime error"),
            .loadingFailed("Load error"),
            .renderingFailed("Render error"),
            .transpositionFailed("Transpose error"),
            .zoomFailed("Zoom error"),
            .invalidZoomLevel(2.5),
            .operationFailed("Operation error")
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    @MainActor
    func testSheetMusicCoordinatorInitialization() {
        let coordinator = SheetMusicCoordinator()

        XCTAssertFalse(coordinator.isLoading)
        XCTAssertFalse(coordinator.isReady)
        XCTAssertNil(coordinator.lastError)
        XCTAssertEqual(coordinator.zoomLevel, 1.0)
    }

    @MainActor
    func testZoomLevelValidation() {
        let coordinator = SheetMusicCoordinator()

        // Test that zoom level is initially 1.0
        XCTAssertEqual(coordinator.zoomLevel, 1.0)

        // Test zoom level bounds in error descriptions
        let invalidZoomError = SheetMusicError.invalidZoomLevel(10.0)
        XCTAssertTrue(invalidZoomError.errorDescription?.contains("between 0.1 and 5.0") == true)

        let zoomFailedError = SheetMusicError.zoomFailed("Test zoom error")
        XCTAssertTrue(zoomFailedError.errorDescription?.contains("Zoom operation failed") == true)
    }
    
    func testSheetMusicCoordinatorNotReadyOperations() async {
        let coordinator = await SheetMusicCoordinator()

        // Test operations when not ready
        do {
            try await coordinator.loadMusicXML("<musicxml></musicxml>")
            XCTFail("Should throw notReady error")
        } catch SheetMusicError.notReady {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        do {
            try await coordinator.transpose(2)
            XCTFail("Should throw notReady error")
        } catch SheetMusicError.notReady {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        do {
            try await coordinator.render()
            XCTFail("Should throw notReady error")
        } catch SheetMusicError.notReady {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        do {
            try await coordinator.clear()
            XCTFail("Should throw notReady error")
        } catch SheetMusicError.notReady {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
