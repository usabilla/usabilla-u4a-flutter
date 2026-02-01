import Flutter
import UIKit
import Usabilla

public class SwiftFlutterUsabillaPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
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
        case "loadFeedbackForm":
            loadFeedbackForm(call: call, result: result)
        case "loadFeedbackFormWithCurrentViewScreenshot":
            loadFeedbackFormWithCurrentViewScreenshot(call: call, result: result)
        case "sendEvent":
            sendEvent(call: call, result: result)
        case "resetCampaignData":
            resetCampaignData(result: result)
        case "dismiss":
            dismiss(result: result)
        case "setCustomVariables":
            setCustomVariables(call: call, result: result)
        case "getDefaultDataMasks":
            getDefaultDataMasks(result: result)
        case "setDataMasking":
            setDataMasking(call: call, result: result)
        case "preloadFeedbackForms":
            preloadFeedbackForms(call: call, result: result)
        case "removeCachedForms":
            removeCachedForms(result: result)
        case "setDebugEnabled":
            setDebugEnabled(call: call, result: result)
        case "loadLocalizedStringFile":
            loadLocalizedStringFile(call: call, result: result)
        case "prePopulateEmailComponent":
            prePopulateEmailComponent(call: call, result: result)
        case "setFooterLogoClickable":
            setFooterLogoClickable(call: call, result: result)
        case "getPlatformVersion":
            result(UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appId = args["appId"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) appId", details: "Expected appId as String"))
            return
        }
        Usabilla.initialize(appID: appId)
        result(nil)
    }

    private func loadFeedbackForm(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let formId = args["formId"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) formId", details: "Expected formId as String"))
            return
        }
        Usabilla.loadFeedbackForm(formId)
        ubFormResult = result
    }

    private func loadFeedbackFormWithCurrentViewScreenshot(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let formId = args["formId"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) formId", details: "Expected formId as String"))
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            result(FlutterError(code: "error", message: "Unable to get root view controller", details: nil))
            return
        }

        let screenshot = self.takeScreenshot(view: rootVC.view)
        Usabilla.loadFeedbackForm(formId, screenshot: screenshot)
        ubFormResult = result
    }

    private func takeScreenshot(view: UIView) -> UIImage {
        let scale: CGFloat = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }

    private func sendEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let event = args["event"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) event", details: "Expected event as String"))
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
        _ = Usabilla.dismiss()
        result(nil)
    }

    private func setCustomVariables(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let variables = args["customVariables"] as? [String: String] else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) customVariables", details: "Expected customVariables as Dictionary of String [String: String]"))
            return
        }
        Usabilla.customVariables = variables
        result(nil)
    }

    private func getDefaultDataMasks(result: @escaping FlutterResult) {
        result(Usabilla.defaultDataMasks)
    }

    private func setDataMasking(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let masks = args["masks"] as? [String] else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) masks", details: "Expected masks as Array"))
            return
        }
        guard let maskChar = args["character"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) maskChar", details: "Expected maskChar as String"))
            return
        }
        guard let maskCharacter = maskChar.first else {
            Usabilla.setDataMasking(masks: Usabilla.defaultDataMasks, maskCharacter: "X")
            result(nil)
            return
        }
        Usabilla.setDataMasking(masks: masks, maskCharacter: maskCharacter)
        result(nil)
    }

    private func preloadFeedbackForms(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let formIDs = args["formIDs"] as? [String] else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) formIDs", details: "Expected formIDs as Array"))
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
        guard let args = call.arguments as? [String: Any],
              let debugEnabled = args["debugEnabled"] as? Bool else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) debugEnabled", details: "Expected debugEnabled as Boolean"))
            return
        }
        Usabilla.debugEnabled = debugEnabled
        result(true)
    }

    private func loadLocalizedStringFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let localizedStringFile = args["localizedStringFile"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) localizedStringFile", details: "Expected localizedStringFile as String"))
            return
        }
        Usabilla.localizedStringFile = localizedStringFile
        result(nil)
    }

    private func prePopulateEmailComponent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let email = args["email"] as? String else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) email", details: "Expected email as String"))
            return
        }
        let editable = (args["editable"] as? Bool) ?? true
        Usabilla.prePopulateEmailComponent(email: email, editable: editable)
        result(nil)
    }

    private func setFooterLogoClickable(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let clickable = args["clickable"] as? Bool else {
            result(FlutterError(code: errorCodeString, message: "\(errorMessageString) clickable", details: "Expected clickable as Boolean"))
            return
        }
        Usabilla.setFooterLogoClickable(clickable)
        result(nil)
    }
}

extension SwiftFlutterUsabillaPlugin: UsabillaDelegate {

    public func formDidLoad(form: UINavigationController) {
        formNavigationController = form
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }
        rootVC.present(form, animated: true, completion: nil)
    }

    public func formDidFailLoading(error: UBError) {
        var ubResults: [[String: Any]] = []
        let dictionary: [String: Any] = ["error": error.description]
        ubResults.append(dictionary)
        formNavigationController = nil
        ubFormResult?(ubResults)
    }

    public func formDidClose(formID: String, withFeedbackResults results: [FeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        var ubResults: [[String: Any]] = []
        for result in results {
            let dictionary: [String: Any] = [
                "rating": result.rating ?? 0,
                "abandonedPageIndex": result.abandonedPageIndex ?? 0,
                "sent": result.sent
            ]
            ubResults.append(dictionary)
        }
        formNavigationController = nil
        let ubResult: [String: Any] = [
            "formId": formID,
            "results": ubResults,
            "isRedirectToAppStoreEnabled": isRedirectToAppStoreEnabled
        ]
        ubFormResult?(ubResult)
    }

    public func campaignDidClose(withFeedbackResult result: FeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        let response: [String: Any] = [
            "rating": result.rating ?? 0,
            "abandonedPageIndex": result.abandonedPageIndex ?? 0,
            "sent": result.sent
        ]
        formNavigationController = nil
        let ubResult: [String: Any] = [
            "result": response,
            "isRedirectToAppStoreEnabled": isRedirectToAppStoreEnabled
        ]
        if ubCampaignResult != nil {
            ubCampaignResult?(ubResult)
            return
        }
        eventSink?(ubResult)
    }
}
