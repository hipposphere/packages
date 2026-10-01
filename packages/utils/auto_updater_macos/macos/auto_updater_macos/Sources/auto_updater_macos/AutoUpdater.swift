import Cocoa
import Sparkle

extension SUAppcast {
    public func toDictionary() -> NSDictionary {
        let dict: NSDictionary = [
            "items": self.items.map({ item in
                return item.toDictionary()
            }),
        ]
        return dict;
    }
}

extension SUAppcastItem {
    
    
    public func toDictionary() -> NSDictionary {
        let dict: NSDictionary = [
            "versionString": self.versionString,
            "displayVersionString": self.displayVersionString,
            "fileURL": self.fileURL?.absoluteString ?? "",
            "contentLength": self.contentLength,
            "infoURL": self.infoURL?.absoluteString ?? "",
            "title":self.title ?? "",
            "dateString": self.dateString ?? "",
            "releaseNotesURL":self.releaseNotesURL?.absoluteString ?? "",
            "itemDescription":self.itemDescription ?? "",
            "itemDescriptionFormat": self.itemDescriptionFormat ?? "",
            "fullReleaseNotesURL": self.fullReleaseNotesURL ?? "",
            "minimumSystemVersion": self.minimumSystemVersion ?? "",
            "minimumOperatingSystemVersionIsOK": self.minimumOperatingSystemVersionIsOK,
            "maximumSystemVersion": self.maximumSystemVersion ?? "",
            "maximumOperatingSystemVersionIsOK": self.maximumOperatingSystemVersionIsOK,
            "channel": self.channel ?? "",
        ]
        return dict;
    }
}

enum AutoUpdaterError: Error {
    case feedURLNotSet
}

/// The Sparkle operations used by the plugin, injectable for native regression tests.
protocol SparkleUpdaterControlling: AnyObject {
    var canCheckForUpdates: Bool { get }
    var sessionInProgress: Bool { get }
    var updateCheckInterval: TimeInterval { get set }
    func start() throws
    func checkForUpdates()
    func checkForUpdatesInBackground()
    func observeCanCheckForUpdates(_ changed: @escaping () -> Void) -> AnyObject
}

extension SPUUpdater: SparkleUpdaterControlling {
    func observeCanCheckForUpdates(_ changed: @escaping () -> Void) -> AnyObject {
        observe(\.canCheckForUpdates) { _, _ in changed() }
    }
}

public class AutoUpdater: NSObject, SPUUpdaterDelegate {
    private var userDriver: SPUStandardUserDriver?
    private var controller: SparkleUpdaterControlling!
    private var readinessObservation: AnyObject?
    private var isStarted = false
    private var startError: Error?
    private var hasPendingUserCheck = false
    private(set) var feedURL: URL?
    public var onEvent: ((String, NSDictionary) -> Void)?

    override init() {
        super.init()
        let hostBundle = Bundle.main
        userDriver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: nil)
        let updater = SPUUpdater(
            hostBundle: hostBundle,
            applicationBundle: hostBundle,
            userDriver: userDriver!,
            delegate: self
        )
        updater.clearFeedURLFromUserDefaults()
        controller = updater
        configure(hasStaticFeed: hostBundle.object(forInfoDictionaryKey: "SUFeedURL") != nil)
    }

    init(controller: SparkleUpdaterControlling, hasStaticFeed: Bool = false) {
        self.controller = controller
        super.init()
        configure(hasStaticFeed: hasStaticFeed)
    }

    private func configure(hasStaticFeed: Bool) {
        readinessObservation = controller.observeCanCheckForUpdates { [weak self] in
            // KVO fires inside Sparkle's state transitions. Recheck readiness on the
            // next main-loop turn, after Sparkle has finished updating its session.
            DispatchQueue.main.async { [weak self] in self?.runPendingUserCheck() }
        }
        // Starting without a feed can disable scheduled updates for this launch.
        // A static feed preserves the normal behavior for Info.plist-based clients.
        if hasStaticFeed {
            do { try start() } catch { /* Retained and returned by the next method call. */ }
        }
    }

    public func feedURLString(for updater: SPUUpdater) -> String? {
        feedURL?.absoluteString
    }

    public func setFeedURL(_ feedURL: URL) throws {
        self.feedURL = feedURL
        try start()
    }

    private func start() throws {
        guard !isStarted else { return }
        do {
            try controller.start()
            isStarted = true
            startError = nil
        } catch {
            startError = error
            throw error
        }
    }

    private func requireStarted() throws {
        guard isStarted else { throw startError ?? AutoUpdaterError.feedURLNotSet }
    }

    public func checkForUpdates() throws {
        try requireStarted()
        if controller.canCheckForUpdates {
            hasPendingUserCheck = false
            controller.checkForUpdates()
        } else {
            // Multiple clicks join one request. A manual future acknowledges that
            // the request was accepted; Sparkle's UI may appear after the download.
            hasPendingUserCheck = true
        }
    }

    private func runPendingUserCheck() {
        guard hasPendingUserCheck, isStarted, controller.canCheckForUpdates else { return }
        hasPendingUserCheck = false
        controller.checkForUpdates()
    }

    public func checkForUpdatesInBackground() throws {
        try requireStarted()
        guard !controller.sessionInProgress else { return }
        controller.checkForUpdatesInBackground()
    }

    public func setScheduledCheckInterval(_ interval: Int) {
        controller.updateCheckInterval = TimeInterval(interval)
    }

    // SPUUpdaterDelegate
    
    public func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        let data: NSDictionary = [
            "error": error.localizedDescription,
        ]
        _emitEvent("error", data);
    }
    
    public func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        let data: NSDictionary = [
            "appcast": appcast.toDictionary()
        ]
        _emitEvent("checking-for-update", data)
    }
    
    public func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        let data: NSDictionary = [
            "appcastItem": item.toDictionary()
        ]
        _emitEvent("update-available", data)
    }
    
    public func updaterDidNotFindUpdate(_ updater: SPUUpdater, error: Error) {
        let data: NSDictionary = [
            "error": error.localizedDescription,
        ]
        _emitEvent("update-not-available", data)
    }
    
    public func updater(_ updater: SPUUpdater, didDownloadUpdate item: SUAppcastItem) {
        let data: NSDictionary = [
            "appcastItem": item.toDictionary()
        ]
        _emitEvent("update-downloaded", data)
    }
    
    public func updater(_ updater: SPUUpdater, willInstallUpdateOnQuit item: SUAppcastItem, immediateInstallationBlock immediateInstallHandler: @escaping () -> Void) -> Bool {
        let data: NSDictionary = [
            "appcastItem": item.toDictionary()
        ]
        _emitEvent("before-quit-for-update", data)
        // This plugin only reports readiness; it does not own installation.
        // Returning true without invoking immediateInstallHandler stalls every
        // later update cycle. Sparkle still installs on quit when we return false.
        return false
    }
    
    public func _emitEvent(_ eventName: String, _ data: NSDictionary) {
        if (onEvent != nil) {
            onEvent!(eventName, data)
        }
    }
}
