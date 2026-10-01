import Flutter
import UIKit
import Usabilla

public class FlutterUsabillaPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink? = nil
    weak var formNavigationController: UINavigationController?
    var ubFormResult: FlutterResult?
    var ubCampaignResult: FlutterResult?
    let errorCodeString: String = "invalidArgs"
    let errorMessageString: String = "Missing arguments"

    override init() {
        super.init()
        Usabilla.delegate = self
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_usabilla", binaryMessenger: registrar.messenger())
        let instance = FlutterUsabillaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: "flutter_usabilla_events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize": initialize(call: call, result: result)
        case "loadFeedbackForm": loadFeedbackForm(call: call, result: result)
        case "loadFeedbackFormWithCurrentViewScreenshot": loadFeedbackFormWithCurrentViewScreenshot(call: call, result: result)
        case "sendEvent": sendEvent(call: call, result: result)
        case "resetCampaignData": resetCampaignData(result: result)
        case "dismiss": dismiss(result: result)
        case "setCustomVariables": setCustomVariables(call: call, result: result)
        case "getDefaultDataMasks": getDefaultDataMasks(result: result)
        case "setDataMasking": setDataMasking(call: call, result: result)
        case "preloadFeedbackForms": preloadFeedbackForms(call: call, result: result)
        case "removeCachedForms": removeCachedForms(result: result)
        case "setDebugEnabled": setDebugEnabled(call: call, result: result)
        case "loadLocalizedStringFile": loadLocalizedStringFile(call: call, result: result)
        case "getPlatformVersion": result(UIDevice.current.systemVersion)
        default: result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appId = (call.arguments as? Dictionary<String, AnyObject>)?["appId"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) appId", details: "Expected appId as String"))
            return
        }
        Usabilla.initialize(appID: appId)
        result(nil)
    }

    private func loadFeedbackForm(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let formId = (call.arguments as? Dictionary<String, AnyObject>)?["formId"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) formId", details: "Expected formId as String"))
            return
        }
        Usabilla.loadFeedbackForm(formId)
        ubFormResult = result
    }

    private func loadFeedbackFormWithCurrentViewScreenshot(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let formId = (call.arguments as? Dictionary<String, AnyObject>)?["formId"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) formId", details: "Expected formId as String"))
            return
        }
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            let screenshot = self.takeScreenshot(view: rootVC.view)
            Usabilla.loadFeedbackForm(formId, screenshot: screenshot)
            ubFormResult = result
        }
    }

    private func takeScreenshot(view: UIView) -> UIImage {
        let scale: CGFloat = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    private func sendEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let event = (call.arguments as? Dictionary<String, AnyObject>)?["event"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) event", details: "Expected event as String"))
            return
        }
        Usabilla.sendEvent(event: event)
        ubCampaignResult = result
    }

    private func resetCampaignData(result: @escaping FlutterResult) { Usabilla.resetCampaignData {}; result(nil) }
    private func dismiss(result: @escaping FlutterResult) { _ = Usabilla.dismiss(); result(nil) }

    private func setCustomVariables(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let variables = (call.arguments as? Dictionary<String, AnyObject>)?["customVariables"] as? [String: String] else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) customVariables", details: "Expected customVariables as Dictionary of String [String: String]"))
            return
        }
        Usabilla.customVariables = variables
        result(nil)
    }

    private func getDefaultDataMasks(result: @escaping FlutterResult) { result(Usabilla.defaultDataMasks) }

    private func setDataMasking(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let masks = (call.arguments as? Dictionary<String, AnyObject>)?["masks"] as? [String] else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) masks", details: "Expected masks as Array"))
            return
        }
        guard let maskChar = (call.arguments as? Dictionary<String, AnyObject>)?["character"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) maskChar", details: "Expected maskChar as String"))
            return
        }
        guard let maskCharacter = maskChar.first else {
            Usabilla.setDataMasking(masks: Usabilla.defaultDataMasks, maskCharacter: "X")
            return
        }
        Usabilla.setDataMasking(masks: masks, maskCharacter: maskCharacter)
        result(nil)
    }

    private func preloadFeedbackForms(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let formIDs = (call.arguments as? Dictionary<String, AnyObject>)?["formIDs"] as? [String] else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) formIDs", details: "Expected formIDs as Array"))
            return
        }
        Usabilla.preloadFeedbackForms(withFormIDs: formIDs)
        result(true)
    }

    private func removeCachedForms(result: @escaping FlutterResult) { Usabilla.removeCachedForms(); result(nil) }

    private func setDebugEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let debugEnabled = (call.arguments as? Dictionary<String, AnyObject>)?["debugEnabled"] as? Bool else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) debugEnabled", details: "Expected debugEnabled as Boolean"))
            return
        }
        Usabilla.debugEnabled = debugEnabled
        result(true)
    }

    private func loadLocalizedStringFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let localizedStringFile = (call.arguments as? Dictionary<String, AnyObject>)?["localizedStringFile"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) localizedStringFile", details: "Expected localizedStringFile as String"))
            return
        }
        Usabilla.localizedStringFile = localizedStringFile
        result(nil)
    }
}

extension FlutterUsabillaPlugin: UsabillaDelegate {
    public func formDidLoad(form: UINavigationController) {
        formNavigationController = form
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(formNavigationController!, animated: true, completion: nil)
        }
    }

    public func formDidFailLoading(error: UBError) {
        let ubResults: [[String: Any]] = [["error": error.description]]
        formNavigationController = nil
        ubFormResult?(ubResults)
    }

    public func formDidClose(formID: String, withFeedbackResults results: [FeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        var ubResults: [[String: Any]] = []
        for result in results {
            ubResults.append(["rating": result.rating ?? 0, "abandonedPageIndex": result.abandonedPageIndex ?? 0, "sent": result.sent])
        }
        formNavigationController = nil
        ubFormResult?(["formId": formID, "results": ubResults, "isRedirectToAppStoreEnabled": isRedirectToAppStoreEnabled])
    }

    public func campaignDidClose(withFeedbackResult result: FeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        let response: [String: Any] = ["rating": result.rating ?? 0, "abandonedPageIndex": result.abandonedPageIndex ?? 0, "sent": result.sent]
        formNavigationController = nil
        let ubResult: [String: Any] = ["result": response, "isRedirectToAppStoreEnabled": isRedirectToAppStoreEnabled]
        if let ubCampaignResult = ubCampaignResult {
            ubCampaignResult(ubResult)
            return
        }
        eventSink?(ubResult)
    }
}