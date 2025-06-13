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
