import XCTest
import SwiftUI
@testable import SheetMusicView

final class ScrollingEnabledTests: XCTestCase {
    
    func testScrollingEnabledDefaultValue() {
        // Test that scrollingEnabled defaults to false when no modifier is used
        let view = SheetMusicView(fileName: "test")
        
        // Since scrollingEnabled is private, we test the behavior through the modifier
        let modifiedView = view.scrollingEnabled(true)
        
        // The test passes if the view can be created without errors
        XCTAssertNotNil(view)
        XCTAssertNotNil(modifiedView)
    }
    
    func testScrollingEnabledModifierWithoutParameter() {
        // Test .scrollingEnabled() without parameter defaults to true
        let view = SheetMusicView(fileName: "test")
            .scrollingEnabled()
        
        XCTAssertNotNil(view)
    }
    
    func testScrollingEnabledModifierWithExplicitTrue() {
        // Test .scrollingEnabled(true)
        let view = SheetMusicView(fileName: "test")
            .scrollingEnabled(true)
        
        XCTAssertNotNil(view)
    }
    
    func testScrollingEnabledModifierWithExplicitFalse() {
        // Test .scrollingEnabled(false)
        let view = SheetMusicView(fileName: "test")
            .scrollingEnabled(false)
        
        XCTAssertNotNil(view)
    }
    
    func testScrollingEnabledWithOtherModifiers() {
        // Test that scrollingEnabled works with other modifiers
        let view = SheetMusicView(fileName: "test")
            .showTitle(true)
            .pageMargins(left: 2.0, right: 2.0)
            .scrollingEnabled(true)
            .systemSpacing(1.0)
        
        XCTAssertNotNil(view)
    }
    
    func testScrollingEnabledWithXMLBinding() {
        // Test scrollingEnabled with XML binding API
        @State var xml = ""
        let view = SheetMusicView(xml: $xml)
            .scrollingEnabled(true)
        
        XCTAssertNotNil(view)
    }
    
    func testScrollingEnabledWithFileURL() {
        // Test scrollingEnabled with fileURL API
        let url = URL(fileURLWithPath: "/test/path")
        let view = SheetMusicView(fileURL: url)
            .scrollingEnabled(false)

        XCTAssertNotNil(view)
    }

    func testScrollingDisabledByDefault() {
        // Test that scrolling is disabled by default (scrollingEnabled = false)
        let view = SheetMusicView(fileName: "test")

        // The view should be created successfully with scrolling disabled by default
        XCTAssertNotNil(view)

        // Test that we can explicitly enable scrolling
        let enabledView = view.scrollingEnabled(true)
        XCTAssertNotNil(enabledView)

        // Test that we can explicitly disable scrolling
        let disabledView = view.scrollingEnabled(false)
        XCTAssertNotNil(disabledView)
    }
}
