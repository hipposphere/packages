import Cocoa
import FlutterMacOS

public class AutoUpdaterMacosPlugin: NSObject, FlutterPlugin,FlutterStreamHandler {
    private var _eventSink: FlutterEventSink?
    
    private let autoUpdater: AutoUpdater

    override init() {
        autoUpdater = AutoUpdater()
        super.init()
    }

    init(autoUpdater: AutoUpdater) {
        self.autoUpdater = autoUpdater
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.leanflutter.plugins/auto_updater", binaryMessenger: registrar.messenger)
        let instance = AutoUpdaterMacosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: "dev.leanflutter.plugins/auto_updater_event", binaryMessenger: registrar.messenger)
        eventChannel.setStreamHandler(instance)
        instance.autoUpdater.onEvent = {
            [weak instance] (eventName: String, eventData: NSDictionary) in
            guard let eventSink = instance?._eventSink else {
                return
            }
            let event: NSDictionary = [
                "type": eventName,
                "data": eventData
            ]
            eventSink(event)
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self._eventSink = events
        return nil;
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self._eventSink = nil
        return nil
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args: [String: Any] = call.arguments as? [String: Any] ?? [:]
        
        do {
            switch call.method {
            case "setFeedURL":
                guard let value = args["feedURL"] as? String,
                      let feedURL = URL(string: value),
                      let scheme = feedURL.scheme, !scheme.isEmpty else {
                    result(FlutterError(code: "invalid-argument", message: "feedURL must be an absolute URL.", details: nil))
                    return
                }
                try autoUpdater.setFeedURL(feedURL)
            case "checkForUpdates":
                guard let inBackground = args["inBackground"] as? Bool else {
                    result(FlutterError(code: "invalid-argument", message: "inBackground must be a boolean.", details: nil))
                    return
                }
                if inBackground {
                    try autoUpdater.checkForUpdatesInBackground()
                } else {
                    try autoUpdater.checkForUpdates()
                }
            case "setScheduledCheckInterval":
                guard let interval = args["interval"] as? Int, interval >= 0 else {
                    result(FlutterError(code: "invalid-argument", message: "interval must be a non-negative integer.", details: nil))
                    return
                }
                autoUpdater.setScheduledCheckInterval(interval)
            default:
                result(FlutterMethodNotImplemented)
                return
            }
            result(true)
        } catch AutoUpdaterError.feedURLNotSet {
            result(FlutterError(code: "feed-url-not-set", message: "Call setFeedURL before checking for updates.", details: nil))
        } catch {
            let error = error as NSError
            result(FlutterError(code: "updater-start-failed", message: error.localizedDescription,
                                details: ["domain": error.domain, "code": error.code]))
        }
    }
}
