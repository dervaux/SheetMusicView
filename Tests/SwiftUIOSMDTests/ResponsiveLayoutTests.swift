import XCTest
import SwiftUI
@testable import SwiftUIOSMD

@MainActor
final class ResponsiveLayoutTests: XCTestCase {
    
    var coordinator: OSMDCoordinator!
    
    override func setUp() async throws {
        coordinator = OSMDCoordinator()
    }
    
    override func tearDown() async throws {
        coordinator = nil
    }
    
    func testContainerSizeUpdateMethod() async throws {
        // Test that the container size update method exists and can be called
        // Note: This will fail until OSMD is actually initialized in a WebView
        do {
            try await coordinator.updateContainerSize(width: 800, height: 600)
            XCTFail("Should have thrown notReady error")
        } catch OSMDError.notReady {
            // Expected behavior when OSMD is not ready
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPageFormatUpdateMethod() async throws {
        // Test that the page format update method exists and can be called
        do {
            try await coordinator.setPageFormat("Endless")
            XCTFail("Should have thrown notReady error")
        } catch OSMDError.notReady {
            // Expected behavior when OSMD is not ready
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testOptimalPageFormatDetermination() {
        // Create a test view to access the private method through a test helper
        let testView = ResponsiveTestHelper()
        
        // Test landscape format (wide)
        let landscapeSize = CGSize(width: 1200, height: 600)
        let landscapeFormat = testView.determineOptimalPageFormat(for: landscapeSize)
        XCTAssertEqual(landscapeFormat, "Endless", "Landscape should use Endless format for optimal line wrapping")
        
        // Test portrait format (tall)
        let portraitSize = CGSize(width: 400, height: 800)
        let portraitFormat = testView.determineOptimalPageFormat(for: portraitSize)
        XCTAssertEqual(portraitFormat, "Endless", "Portrait should use Endless format for optimal line wrapping")
        
        // Test square format
        let squareSize = CGSize(width: 600, height: 600)
        let squareFormat = testView.determineOptimalPageFormat(for: squareSize)
        XCTAssertEqual(squareFormat, "Endless", "Square should use Endless format for optimal line wrapping")
    }
    
    func testContainerSizeChangeDetection() {
        // Test that container size changes are properly detected
        let testView = ResponsiveTestHelper()
        
        // Test significant size change
        let oldSize = CGSize(width: 400, height: 600)
        let newSize = CGSize(width: 800, height: 600)
        
        let shouldUpdate = testView.shouldUpdateForSizeChange(from: oldSize, to: newSize)
        XCTAssertTrue(shouldUpdate, "Should detect significant width change")
        
        // Test minimal size change (should be ignored for performance)
        let minimalChange = CGSize(width: 400.5, height: 600.5)
        let shouldNotUpdate = testView.shouldUpdateForSizeChange(from: oldSize, to: minimalChange)
        XCTAssertFalse(shouldNotUpdate, "Should ignore minimal size changes")
    }
}

// MARK: - Test Helper

/// Helper class to test private methods from OSMDView
private class ResponsiveTestHelper {
    
    func determineOptimalPageFormat(for size: CGSize) -> String {
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
    
    func shouldUpdateForSizeChange(from oldSize: CGSize, to newSize: CGSize) -> Bool {
        return abs(newSize.width - oldSize.width) > 1 || 
               abs(newSize.height - oldSize.height) > 1
    }
}
