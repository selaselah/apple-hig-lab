import XCTest

final class HIGLabUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-appearance", "light"]
        app.launch()
    }

    func testPresetsUpdateRealGaugesAndReset() {
        XCTAssertTrue(app.staticTexts["live-value"].waitForExistence(timeout: 10))
        app.buttons["preset-100"].tap()
        XCTAssertEqual(app.staticTexts["live-value"].label, "100%")
        let gauge = app.descendants(matching: .any)["gauge-accessoryCircular"].firstMatch
        XCTAssertTrue(gauge.exists)
        XCTAssertTrue((gauge.value as? String ?? "").contains("100%"))
        app.buttons["preset-0"].tap()
        XCTAssertEqual(app.staticTexts["live-value"].label, "0%")
        app.buttons["reset-demo"].tap()
        XCTAssertEqual(app.staticTexts["live-value"].label, "64%")
    }

    func testCodeExampleIsInspectable() {
        app.scrollViews["gauge-scroll"].swipeUp()
        let codeButton = app.buttons["code-automatic"]
        for _ in 0..<5 {
            if codeButton.isHittable { break }
            app.scrollViews["gauge-scroll"].swipeUp()
        }
        XCTAssertTrue(codeButton.isHittable)
        codeButton.tap()
        let source = app.descendants(matching: .any)["swiftui-source"].firstMatch
        XCTAssertTrue(source.waitForExistence(timeout: 5))
        XCTAssertTrue(source.label.contains(".gaugeStyle(.automatic)"))
        app.buttons["完成"].tap()
    }

    func testScenarioThresholdAndTemperature() {
        app.buttons["nav-场景演示"].tap()
        XCTAssertTrue(app.buttons["temperature-cold"].waitForExistence(timeout: 5))
        app.buttons["temperature-cold"].tap()
        XCTAssertEqual(app.staticTexts["temperature-value"].label, "-5°C")
        app.buttons["temperature-hot"].tap()
        XCTAssertEqual(app.staticTexts["temperature-value"].label, "38°C")
        app.scrollViews["gauge-scroll"].swipeUp()
        let low = app.buttons["battery-low"]
        for _ in 0..<4 {
            if low.isHittable { break }
            app.scrollViews["gauge-scroll"].swipeUp()
        }
        low.tap()
        XCTAssertEqual(app.staticTexts["battery-status"].label, "低电量")
        app.buttons["battery-full"].tap()
        XCTAssertEqual(app.staticTexts["battery-status"].label, "电量充足")
    }

    func testSystemMoreOpensOverflowTabAndDisappearsWithFourTabs() {
        let entry = app.buttons["nav-tab-bars"]
        XCTAssertTrue(entry.waitForExistence(timeout: 10))
        entry.tap()
        app.buttons["open-tab-demo"].tap()
        let more = app.tabBars.buttons["system-more-tab"]
        XCTAssertTrue(more.waitForExistence(timeout: 5))
        more.tap()
        let listScreenshot = XCTAttachment(screenshot: app.screenshot())
        listScreenshot.name = "Tab Bars - native More list"
        listScreenshot.lifetime = .keepAlways
        add(listScreenshot)
        let downloads = app.tables.cells.containing(.staticText, identifier: "下载").firstMatch
        XCTAssertTrue(downloads.waitForExistence(timeout: 5))
        downloads.tap()
        XCTAssertTrue(app.staticTexts["demo-page-downloads"].waitForExistence(timeout: 5))
        app.segmentedControls["tab-count"].buttons["4 个"].tap()
        XCTAssertFalse(more.exists)
        XCTAssertTrue(app.staticTexts["demo-page-home"].exists)
        app.buttons["close-tab-demo"].tap()
    }
}
