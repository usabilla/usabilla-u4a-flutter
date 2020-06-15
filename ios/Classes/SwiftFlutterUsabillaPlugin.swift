import Flutter
import UIKit
import Usabilla

public class SwiftFlutterUsabillaPlugin: NSObject, FlutterPlugin {

    weak var formNavigationController: UINavigationController?
    var ubFormResult: FlutterResult?
    var ubCampaignResult: FlutterResult?

    override init() {
        super.init()
        Usabilla.delegate = self
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_usabilla", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterUsabillaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            _init(appId: (call.arguments as! Dictionary<String, AnyObject>)["appId"] as! String)
            result(nil)
            break
        case "getPlatformVersion":
            result(UIDevice.current.systemVersion)
            break
        case "loadFeedbackForm":
            _loadFeedbackForm(result: result, formId: (call.arguments as! Dictionary<String, AnyObject>)["formId"] as! String)
            break
        case "loadFeedbackFormWithCurrentViewScreenshot":
            _loadFeedbackFormWithCurrentViewScreenshot(result: result, formId: (call.arguments as! Dictionary<String, AnyObject>)["formId"] as! String)
            break
        case "sendEvent":
            _sendEvent(result: result, event: (call.arguments as! Dictionary<String, AnyObject>)["event"] as! String)
            break
        case "resetCampaignData":
            _resetCampaignData()
            result(nil)
            break
        case "setCustomVariables":
            _setCustomVariables(variables: (call.arguments as! Dictionary<String, AnyObject>)["customVariables"] as! [String: Any])
            result(nil)
            break
        case "dismiss":
            _dismiss()
            result(nil)
            break
        case "getDefaultDataMasks":
            result(Usabilla.defaultDataMasks)
            break
        case "setDataMasking":
            _setDataMasking(masks: (call.arguments as! Dictionary<String, AnyObject>)["masks"] as! [String], maskChar: (call.arguments as! Dictionary<String, AnyObject>)["character"] as! String)
            result(nil)
            break
        case "localizedStringFile":
            _loadLocalizedStringFile(localizedStringFile: (call.arguments as! Dictionary<String, AnyObject>)["localizedStringFile"] as! String)
            result(nil)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func _init(appId: String) {
        print("initialize inside called")
        Usabilla.initialize(appID: appId)
    }

    private func _sendEvent(result: @escaping FlutterResult, event: String) {
        Usabilla.sendEvent(event: event)
        ubCampaignResult = result
    }

    private func _resetCampaignData() {
        Usabilla.resetCampaignData {}
    }

    private func _dismiss() {
        let _ = Usabilla.dismiss()
    }

    private func _setDataMasking(masks: [String], maskChar: String) {
        guard let maskCharacter = maskChar.first
            else {
                Usabilla.setDataMasking(masks: Usabilla.defaultDataMasks, maskCharacter: "X")
                return
        }
        Usabilla.setDataMasking(masks: masks, maskCharacter: maskCharacter)
    }

    private func _setCustomVariables(variables: [String: Any]) {
        let newCustomVariables = variables.mapValues { String(describing: $0) }
        Usabilla.customVariables = newCustomVariables
    }

    private func _removeCachedForms() {
        Usabilla.removeCachedForms()
    }

    private func _loadLocalizedStringFile(localizedStringFile: String) {
        Usabilla.localizedStringFile = localizedStringFile
    }

    private func _loadFeedbackForm(result: @escaping FlutterResult, formId: String) {
        Usabilla.loadFeedbackForm(formId)
        ubFormResult = result
    }

    private func _loadFeedbackFormWithCurrentViewScreenshot(result: @escaping FlutterResult, formId: String) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            let screenshot = self.takeScreenshot(view: rootVC.view)
            Usabilla.loadFeedbackForm(formId, screenshot: screenshot)
            ubFormResult = result
        }
    }

    private func takeScreenshot(view: UIView) -> UIImage {
        return Usabilla.takeScreenshot(view)!
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
        ubFormResult!(rnResults)
    }

    public func formDidClose(formID: String, withFeedbackResults results: [FeedbackResult], isRedirectToAppStoreEnabled: Bool) {
        var ubResults: [[String : Any]] = []
        for result in results {
            let dictionary: Dictionary = ["rating": result.rating ?? 0, "abandonedPageIndex": result.abandonedPageIndex ?? 0, "sent": result.sent] as [String : Any]
            ubResults.append(dictionary)
        }
        formNavigationController = nil
        let ubResult: [String : Any] = ["formId": formID, "results": ubResults, "isRedirectToAppStoreEnabled": isRedirectToAppStoreEnabled]
        ubFormResult!(ubResult)
    }

    public func campaignDidClose(withFeedbackResult result: FeedbackResult, isRedirectToAppStoreEnabled: Bool) {
        let response: [String : Any] = ["rating": result.rating ?? 0, "abandonedPageIndex": result.abandonedPageIndex ?? 0, "sent": result.sent] as [String : Any]
        formNavigationController = nil
        let ubResult: [String : Any] = ["result": response, "isRedirectToAppStoreEnabled": isRedirectToAppStoreEnabled]
        ubCampaignResult!(ubResult)
    }
}

