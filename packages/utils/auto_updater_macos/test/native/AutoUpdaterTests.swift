import Cocoa
import FlutterMacOS
import Sparkle
import XCTest

private final class FakeUpdater: SparkleUpdaterControlling {
    var canCheckForUpdates = true { didSet { changed?() } }
    var sessionInProgress = false
    var updateCheckInterval: TimeInterval = 86400
    var startCalls = 0
    var manualChecks = 0
    var backgroundChecks = 0
    var startFailure: Error?
    var onManualCheck: (() -> Void)?
    private var changed: (() -> Void)?

    func start() throws {
        startCalls += 1
        if let error = startFailure { throw error }
    }
    func checkForUpdates() {
        manualChecks += 1
        onManualCheck?()
    }
    func checkForUpdatesInBackground() { backgroundChecks += 1 }
    func observeCanCheckForUpdates(_ changed: @escaping () -> Void) -> AnyObject {
        self.changed = changed
        return NSObject()
    }
}

final class AutoUpdaterTests: XCTestCase {
    private let feed = URL(string: "https://example.test/appcast.xml")!
    private func drainMainQueue() {
        let finished = expectation(description: "main queue drained")
        DispatchQueue.main.async { finished.fulfill() }
        wait(for: [finished], timeout: 1)
    }
    private func readyUpdater(_ driver: FakeUpdater) throws -> AutoUpdater {
        let updater = AutoUpdater(controller: driver)
        try updater.setFeedURL(feed)
        return updater
    }
    private func call(_ plugin: AutoUpdaterMacosPlugin, _ method: String, _ args: Any?) -> Any? {
        var results = [Any?]()
        plugin.handle(FlutterMethodCall(methodName: method, arguments: args)) { results.append($0) }
        XCTAssertEqual(results.count, 1)
        return results.first ?? nil
    }
    private func assertError(_ value: Any?, _ code: String) {
        XCTAssertEqual((value as? FlutterError)?.code, code)
    }

    func testDynamicFeedDefersStartup() throws {
        let driver = FakeUpdater()
        let updater = AutoUpdater(controller: driver)
        XCTAssertEqual(driver.startCalls, 0)
        XCTAssertThrowsError(try updater.checkForUpdates()) { error in
            guard case AutoUpdaterError.feedURLNotSet = error else { return XCTFail("Unexpected error") }
        }
        XCTAssertThrowsError(try updater.checkForUpdatesInBackground())
        try updater.setFeedURL(feed)
        XCTAssertEqual(driver.startCalls, 1)
        XCTAssertEqual(updater.feedURL, feed)
        try updater.setFeedURL(URL(string: "https://example.test/alpha.xml")!)
        XCTAssertEqual(driver.startCalls, 1)
        XCTAssertEqual(updater.feedURL?.lastPathComponent, "alpha.xml")
    }
    func testStaticFeedStartsImmediately() throws {
        let driver = FakeUpdater()
        let updater = AutoUpdater(controller: driver, hasStaticFeed: true)
        XCTAssertEqual(driver.startCalls, 1)
        try updater.checkForUpdates()
        XCTAssertEqual(driver.manualChecks, 1)
    }
    func testFailedStartupCanBeRetried() throws {
        let driver = FakeUpdater()
        driver.startFailure = NSError(domain: "fixture", code: 17)
        let updater = AutoUpdater(controller: driver)
        XCTAssertThrowsError(try updater.setFeedURL(feed))
        XCTAssertThrowsError(try updater.checkForUpdates()) { error in
            XCTAssertEqual((error as NSError).domain, "fixture")
        }
        driver.startFailure = nil
        try updater.setFeedURL(feed)
        try updater.checkForUpdates()
        XCTAssertEqual(driver.startCalls, 2)
        XCTAssertEqual(driver.manualChecks, 1)
    }
    func testStaticStartupFailureIsReported() {
        let driver = FakeUpdater()
        driver.startFailure = NSError(domain: "static-fixture", code: 18)
        let updater = AutoUpdater(controller: driver, hasStaticFeed: true)
        let plugin = AutoUpdaterMacosPlugin(autoUpdater: updater)
        let result = call(plugin, "checkForUpdates", ["inBackground": false]) as? FlutterError
        XCTAssertEqual(result?.code, "updater-start-failed")
        XCTAssertEqual((result?.details as? [String: Any])?["domain"] as? String, "static-fixture")
    }
    func testManualChecksAreCoalescedAndDeferred() throws {
        let driver = FakeUpdater()
        let updater = try readyUpdater(driver)
        driver.canCheckForUpdates = false
        driver.sessionInProgress = true
        for _ in 0..<3 { try updater.checkForUpdates() }
        XCTAssertEqual(driver.manualChecks, 0)
        driver.canCheckForUpdates = true
        XCTAssertEqual(driver.manualChecks, 0, "Must not reenter Sparkle from KVO")
        driver.sessionInProgress = false
        driver.onManualCheck = {
            XCTAssertFalse(driver.sessionInProgress, "Sparkle's transition must have finished")
            driver.canCheckForUpdates = false
        }
        drainMainQueue()
        XCTAssertEqual(driver.manualChecks, 1)
        driver.canCheckForUpdates = true
        drainMainQueue()
        XCTAssertEqual(driver.manualChecks, 1)
    }
    func testReadinessIsRecheckedAfterDispatch() throws {
        let driver = FakeUpdater()
        let updater = try readyUpdater(driver)
        driver.canCheckForUpdates = false
        try updater.checkForUpdates()
        driver.canCheckForUpdates = true
        driver.canCheckForUpdates = false
        drainMainQueue()
        XCTAssertEqual(driver.manualChecks, 0)
        driver.canCheckForUpdates = true
        drainMainQueue()
        XCTAssertEqual(driver.manualChecks, 1)
    }
    func testImmediateCheckConsumesPendingRequest() throws {
        let driver = FakeUpdater()
        let updater = try readyUpdater(driver)
        driver.canCheckForUpdates = false
        try updater.checkForUpdates()
        driver.canCheckForUpdates = true
        try updater.checkForUpdates()
        drainMainQueue()
        XCTAssertEqual(driver.manualChecks, 1)
    }
    func testVisibleUpdateCanBeFocusedDuringSession() throws {
        let driver = FakeUpdater()
        let updater = try readyUpdater(driver)
        driver.sessionInProgress = true
        try updater.checkForUpdates()
        XCTAssertEqual(driver.manualChecks, 1)
    }
    func testBackgroundChecksSkipActiveSession() throws {
        let driver = FakeUpdater()
        let updater = try readyUpdater(driver)
        driver.sessionInProgress = true
        try updater.checkForUpdatesInBackground()
        XCTAssertEqual(driver.backgroundChecks, 0)
        driver.sessionInProgress = false
        try updater.checkForUpdatesInBackground()
        XCTAssertEqual(driver.backgroundChecks, 1)
    }
    func testIntervalCanBeSetBeforeStartup() {
        let driver = FakeUpdater()
        let updater = AutoUpdater(controller: driver)
        updater.setScheduledCheckInterval(3600)
        XCTAssertEqual(driver.updateCheckInterval, 3600)
        XCTAssertEqual(driver.startCalls, 0)
    }
    func testDeallocatedUpdaterDoesNotRunPendingCheck() throws {
        let driver = FakeUpdater()
        var updater: AutoUpdater? = try readyUpdater(driver)
        weak let reference = updater
        driver.canCheckForUpdates = false
        try updater?.checkForUpdates()
        driver.canCheckForUpdates = true
        updater = nil
        drainMainQueue()
        XCTAssertNil(reference)
        XCTAssertEqual(driver.manualChecks, 0)
    }
    func testInstallOnQuitReleasesSessionAndKeepsEvent() throws {
        let driver = FakeUpdater()
        let updater = AutoUpdater(controller: driver)
        let native = SPUUpdater(hostBundle: .main, applicationBundle: .main,
                                userDriver: SPUStandardUserDriver(hostBundle: .main, delegate: nil),
                                delegate: updater)
        let item = SUAppcastItem(dictionary: ["title": "Fixture", "enclosure": ["url": "https://example.test/Fixture_2.zip", "sparkle:version": "2", "length": "1024"]])
        var event: String?
        updater.onEvent = { name, data in
            event = name
            XCTAssertNotNil(data["appcastItem"])
        }
        var handlerCalled = false
        XCTAssertFalse(updater.updater(native, willInstallUpdateOnQuit: try XCTUnwrap(item),
                                       immediateInstallationBlock: { handlerCalled = true }))
        XCTAssertEqual(event, "before-quit-for-update")
        XCTAssertFalse(handlerCalled)
    }
    func testPluginRejectsInvalidArguments() {
        let driver = FakeUpdater()
        let plugin = AutoUpdaterMacosPlugin(autoUpdater: AutoUpdater(controller: driver))
        for args: Any in [[String: Any](), ["feedURL": 12], ["feedURL": "relative.xml"]] {
            assertError(call(plugin, "setFeedURL", args), "invalid-argument")
        }
        for args: Any in [[String: Any](), ["inBackground": "false"]] {
            assertError(call(plugin, "checkForUpdates", args), "invalid-argument")
        }
        for args: Any in [[String: Any](), ["interval": -1], ["interval": "3600"]] {
            assertError(call(plugin, "setScheduledCheckInterval", args), "invalid-argument")
        }
        XCTAssertEqual(driver.startCalls, 0)
    }
    func testPluginReportsMissingFeed() {
        let driver = FakeUpdater()
        let plugin = AutoUpdaterMacosPlugin(autoUpdater: AutoUpdater(controller: driver))
        for background in [false, true] {
            assertError(call(plugin, "checkForUpdates", ["inBackground": background]), "feed-url-not-set")
        }
    }
    func testPluginReportsStartupErrorDetails() {
        let driver = FakeUpdater()
        driver.startFailure = NSError(domain: "SparkleFixture", code: 42,
                                       userInfo: [NSLocalizedDescriptionKey: "Invalid signing key"])
        let plugin = AutoUpdaterMacosPlugin(autoUpdater: AutoUpdater(controller: driver))
        let result = call(plugin, "setFeedURL", ["feedURL": feed.absoluteString]) as? FlutterError
        XCTAssertEqual(result?.code, "updater-start-failed")
        XCTAssertEqual(result?.message, "Invalid signing key")
        XCTAssertEqual((result?.details as? [String: Any])?["code"] as? Int, 42)
        assertError(call(plugin, "checkForUpdates", ["inBackground": false]), "updater-start-failed")
    }
    func testPluginAcknowledgesQueuedCheck() throws {
        let driver = FakeUpdater()
        let updater = try readyUpdater(driver)
        let plugin = AutoUpdaterMacosPlugin(autoUpdater: updater)
        driver.canCheckForUpdates = false
        XCTAssertEqual(call(plugin, "checkForUpdates", ["inBackground": false]) as? Bool, true)
        XCTAssertEqual(driver.manualChecks, 0)
        driver.canCheckForUpdates = true
        drainMainQueue()
        XCTAssertEqual(driver.manualChecks, 1)
    }
    func testPluginUnknownMethodIsNotImplemented() {
        let driver = FakeUpdater()
        let plugin = AutoUpdaterMacosPlugin(autoUpdater: AutoUpdater(controller: driver))
        XCTAssertTrue((call(plugin, "unknown", nil) as? NSObject) === FlutterMethodNotImplemented)
    }
}
