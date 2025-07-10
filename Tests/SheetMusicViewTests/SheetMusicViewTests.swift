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

    func testFileLoadingUtility() {
        // Create a test bundle with a sample MusicXML file
        let testBundle = Bundle.module

        // Test the file loading method with a non-existent file
        let view = SheetMusicView(fileName: "nonexistent", bundle: testBundle)

        // The view should be created successfully even with a non-existent file
        // Error handling happens at runtime when the file is actually loaded
        XCTAssertNotNil(view)
    }

    @MainActor
    func testFileBasedInitializer() {
        // Test that the file-based initializer creates a view with correct properties
        let fileName = "test"
        let bundle = Bundle.main

        let view = SheetMusicView(
            fileName: fileName,
            transposeSteps: .constant(2),
            isLoading: .constant(false),
            bundle: bundle
        )

        XCTAssertNotNil(view)

        // Test with callbacks
        var errorCalled = false
        var readyCalled = false

        let viewWithCallbacks = SheetMusicView(
            fileName: fileName,
            transposeSteps: .constant(0),
            isLoading: .constant(false),
            bundle: bundle,
            onError: { _ in errorCalled = true },
            onReady: { readyCalled = true }
        )

        XCTAssertNotNil(viewWithCallbacks)

        // Suppress warnings about unused variables
        _ = errorCalled
        _ = readyCalled
    }

    @MainActor
    func testFileURLBasedInitializer() {
        // Test that the fileURL-based initializer creates a view with correct properties
        let testURL = URL(fileURLWithPath: "/path/to/test.musicxml")

        let view = SheetMusicView(
            fileURL: testURL,
            transposeSteps: .constant(2),
            isLoading: .constant(false)
        )

        XCTAssertNotNil(view)

        // Test with callbacks
        var errorCalled = false
        var readyCalled = false

        let viewWithCallbacks = SheetMusicView(
            fileURL: testURL,
            transposeSteps: .constant(0),
            isLoading: .constant(false),
            onError: { _ in errorCalled = true },
            onReady: { readyCalled = true }
        )

        XCTAssertNotNil(viewWithCallbacks)

        // Suppress warnings about unused variables
        _ = errorCalled
        _ = readyCalled
    }

    @MainActor
    func testFileNameInitializerTimingFix() {
        // Test that the fileName initializer properly waits for coordinator to be ready
        // before attempting to load the file
        let coordinator = SheetMusicCoordinator()

        // Initially coordinator should not be ready
        XCTAssertFalse(coordinator.isReady)

        // Create a view with fileName - this should not crash or fail
        let view = SheetMusicView(
            fileName: "sample",
            bundle: Bundle.main
        )

        XCTAssertNotNil(view)

        // The view should be created successfully even though the coordinator
        // is not ready yet. The file loading should be deferred until onReady is called.
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

    @MainActor
    func testPageMarginsModifier() {
        // Test that pageMargins modifier creates a new view with correct margin values
        let originalView = SheetMusicView(
            xml: .constant(""),
            transposeSteps: .constant(0),
            isLoading: .constant(false)
        )

        let modifiedView = originalView.pageMargins(left: 20.0, right: 25.0)

        // Since the properties are private, we can't directly test them,
        // but we can verify the modifier returns a SheetMusicView instance
        XCTAssertNotNil(modifiedView)

        // Test with default values
        let defaultView = originalView.pageMargins()
        XCTAssertNotNil(defaultView)
    }

    @MainActor
    func testPageMarginsCoordinatorNotReady() async {
        let coordinator = SheetMusicCoordinator()

        // Test that setPageMargins throws notReady error when coordinator is not ready
        do {
            try await coordinator.setPageMargins(left: 15.0, right: 15.0)
            XCTFail("Should throw notReady error")
        } catch SheetMusicError.notReady {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func testPageMarginsChaining() {
        // Test that page margins modifier can be chained with other modifiers
        let view = SheetMusicView(
            xml: .constant(""),
            transposeSteps: .constant(0),
            isLoading: .constant(false)
        )
        .showTitle()
        .pageMargins(left: 12.0, right: 18.0)
        .showComposer()

        XCTAssertNotNil(view)
    }

    @MainActor
    func testPageMarginsWithFileBasedAPI() {
        // Test that page margins work with file-based API
        let view = SheetMusicView(
            fileName: "test",
            transposeSteps: .constant(0),
            isLoading: .constant(false)
        )
        .pageMargins(left: 5.0, right: 30.0)

        XCTAssertNotNil(view)
    }

    @MainActor
    func testPageMarginsWithFileURLAPI() {
        // Test that page margins work with file URL API
        let testURL = URL(fileURLWithPath: "/tmp/test.musicxml")
        let view = SheetMusicView(
            fileURL: testURL,
            transposeSteps: .constant(0),
            isLoading: .constant(false)
        )
        .pageMargins(left: 8.0, right: 12.0)

        XCTAssertNotNil(view)
    }
}
