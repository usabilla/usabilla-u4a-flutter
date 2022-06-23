import Flutter
import UIKit
import Usabilla

public class SwiftFlutterUsabillaPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
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
        let instance = SwiftFlutterUsabillaPlugin()
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
        case "initialize":
            initialize(call: call, result: result)
            break
        case "loadFeedbackForm":
            loadFeedbackForm(call: call, result: result)
            break
        case "loadFeedbackFormWithCurrentViewScreenshot":
            loadFeedbackFormWithCurrentViewScreenshot(call: call, result: result)
            break
        case "sendEvent":
            sendEvent(call: call, result: result)
            break
        case "resetCampaignData":
            resetCampaignData(result: result)
            break
        case "dismiss":
            dismiss(result: result)
            break
        case "setCustomVariables":
            setCustomVariables(call: call, result: result)
            break
        case "getDefaultDataMasks":
            getDefaultDataMasks(result: result)
            break
        case "setDataMasking":
            setDataMasking(call: call, result: result)
            break
        case "preloadFeedbackForms":
            preloadFeedbackForms(call: call, result: result)
            break
        case "removeCachedForms":
            removeCachedForms(result: result)
            break
        case "setDebugEnabled":
            setDebugEnabled(call: call, result: result)
            break
        case "loadLocalizedStringFile":
            loadLocalizedStringFile(call: call, result: result)
            break
        case "getPlatformVersion":
            result(UIDevice.current.systemVersion)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appId = (call.arguments as? Dictionary<String, AnyObject>)?["appId"] as? String else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) appId", details: "Expected appId as String"))
            return
        }
        Usabilla.initialize(appID: appId)
        result(nil)
    }

    private func loadFeedbackForm(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let formId = (call.arguments as? Dictionary<String, AnyObject>)?["formId"] as? String else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) formId", details: "Expected formId as String"))
            return
        }
        Usabilla.loadFeedbackForm(formId)
        ubFormResult = result
    }

    private func loadFeedbackFormWithCurrentViewScreenshot(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let formId = (call.arguments as? Dictionary<String, AnyObject>)?["formId"] as? String else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) formId", details: "Expected formId as String"))
            return
        }
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            let screenshot = self.takeScreenshot(view: rootVC.view)
            Usabilla.loadFeedbackForm(formId, screenshot: screenshot)
            ubFormResult = result
        }
    }

    private func takeScreenshot(view: UIView) -> UIImage {
        //FIXME Need to fix Usabilla.takeScreenshot(view)!
        // - it produces half of image which is zoomed double.
        //return Usabilla.takeScreenshot(view)!
        let scale :CGFloat = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image :UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    private func sendEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let event = (call.arguments as? Dictionary<String, AnyObject>)?["event"] as? String else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) event", details: "Expected event as String"))
            return
        }
        Usabilla.sendEvent(event: event)
        ubCampaignResult = result
    }

    private func resetCampaignData(result: @escaping FlutterResult) {
        Usabilla.resetCampaignData {}
        result(nil)
    }

    private func dismiss(result: @escaping FlutterResult) {
        let _ = Usabilla.dismiss()
        result(nil)
    }

    private func setCustomVariables(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let variables = (call.arguments as? Dictionary<String, AnyObject>)?["customVariables"] as? [String: String] else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) customVariables", details: "Expected customVariables as Dictionary of String [String: String]"))
            return
        }
        Usabilla.customVariables = variables
    }

    private func getDefaultDataMasks(result: @escaping FlutterResult) {
        result(Usabilla.defaultDataMasks)
    }

    private func setDataMasking(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let masks = (call.arguments as? Dictionary<String, AnyObject>)?["masks"] as? [String] else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) masks", details: "Expected masks as Array"))
            return
        }
        guard let maskChar = (call.arguments as? Dictionary<String, AnyObject>)?["character"] as? String else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) maskChar", details: "Expected maskChar as String"))
            return
        }
        guard let maskCharacter = maskChar.first
            else {
                Usabilla.setDataMasking(masks: Usabilla.defaultDataMasks, maskCharacter: "X")
                return
        }
        Usabilla.setDataMasking(masks: masks, maskCharacter: maskCharacter)
        result(nil)
    }

    private func preloadFeedbackForms(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let formIDs = (call.arguments as? Dictionary<String, AnyObject>)?["formIDs"] as? [String] else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) formIDs", details: "Expected formIDs as Array"))
            return
        }
        Usabilla.preloadFeedbackForms(withFormIDs: formIDs)
        result(true)
    }

    private func removeCachedForms(result: @escaping FlutterResult) {
        Usabilla.removeCachedForms()
        result(nil)
    }

    private func setDebugEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let debugEnabled = (call.arguments as? Dictionary<String, AnyObject>)?["debugEnabled"] as? Bool else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) debugEnabled", details: "Expected debugEnabled as Boolean"))
            return
        }
        Usabilla.debugEnabled = debugEnabled
        result(true)
    }

    private func loadLocalizedStringFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let localizedStringFile = (call.arguments as? Dictionary<String, AnyObject>)?["localizedStringFile"] as? String else {
            result(FlutterError( code: errorCodeString, message: "\(errorMessageString) localizedStringFile", details: "Expected localizedStringFile as String"))
            return
        }
        Usabilla.localizedStringFile = localizedStringFile
        result(nil)
    }
}

extension SwiftFlutterUsabillaPlugin: UsabillaDelegate {

    public func formDidLoad(form: UINavigationController) {
        formNavigationController = form
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(formNavigationController!, animated: true, completion: nil)
        }
    }

    public func formDidFailLoading(error: UBError) {
        var rnResults: [[String : Any]] = []
        let dictionary: Dictionary = ["error": error.description]
        rnResults.append(dictionary)
        formNavigationController = nil
        if (ubFormResult != nil) {
            ubFormResult!(ubResult)
            return
        }
    }

    public func formDidClose(formID: String, withFeedbackResults results: [FeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        var ubResults: [[String : Any]] = []
        for result in results {
            let dictionary: Dictionary = ["rating": result.rating ?? 0, "abandonedPageIndex": result.abandonedPageIndex ?? 0, "sent": result.sent] as [String : Any]
            ubResults.append(dictionary)
        }
        formNavigationController = nil
        let ubResult: [String : Any] = ["formId": formID, "results": ubResults, "isRedirectToAppStoreEnabled": isRedirectToAppStoreEnabled]
        if (ubFormResult != nil) {
            ubFormResult!(ubResult)
            return
        }
    }

    public func campaignDidClose(withFeedbackResult result: FeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        let response: [String : Any] = ["rating": result.rating ?? 0, "abandonedPageIndex": result.abandonedPageIndex ?? 0, "sent": result.sent] as [String : Any]
        formNavigationController = nil
        let ubResult: [String : Any] = ["result": response, "isRedirectToAppStoreEnabled": isRedirectToAppStoreEnabled]
        if (ubCampaignResult != nil) {
            ubCampaignResult!(ubResult)
            return
        }
        guard let eventSink = eventSink else { return }
        eventSink(ubResult)
    }
}

