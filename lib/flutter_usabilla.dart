import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

///FlutterUsabilla flutter wrapper for usabilla sdk.
class FlutterUsabilla {
  static const MethodChannel _channel = const MethodChannel('flutter_usabilla');
  static const EventChannel _eventChannel = const EventChannel("flutter_usabilla_events");

  static Future<Stream> standardEventsData() async {
    Stream _stream;
    _stream = _eventChannel.receiveBroadcastStream();
    return _stream;
  }

  /// Gives the current platform version.
  static Future<String?> get platformVersion async {
    return await _channel.invokeMethod('getPlatformVersion');
  }

  /// Manually Dismiss the Forms / Campaign.
  static Future<void> dismiss() async {
    await _channel.invokeMethod('dismiss');
  }

  /// Sets custom variables for targeting Campaigns.
  static Future<void> setCustomVariables(Map<String, String> customVariables) async {
    await _channel.invokeMethod('setCustomVariables', <String, dynamic>{
      'customVariables': customVariables,
    });
  }

  /// Sets data masking with default character / passed single character and based on masks rule.
  static Future<void> setDataMasking(List masks, String character) async {
    await _channel.invokeMethod('setDataMasking',
        <String, dynamic>{'masks': masks, 'character': character});
  }

  /// Returns masks List to check what is the defined rule.
  static Future<List?> get defaultDataMasks async {
    return await _channel.invokeMethod('getDefaultDataMasks');
  }

  /// Load the Campaign & Returns a Map, contains result - rating, pageindex, sent flag.
  static Future<Map?> sendEvent(String event) async {
    return await _channel.invokeMethod('sendEvent', <String, dynamic>{ 'event': event });
  }

  /// Remove cached forms.
  static Future<void> removeCachedForms() async {
    await _channel.invokeMethod('removeCachedForms');
  }

  /// Reset Campaign, so can be triggered from fresh count.
  static Future<void> resetCampaignData() async {
    await _channel.invokeMethod('resetCampaignData');
  }

  /// Initialize the SDK, using appID.
  static Future<void> initialize(String appId) async {
    await _channel.invokeMethod('initialize', <String, dynamic>{
      'appId': appId,
    });
  }

  /// Load the Passive Form, using formId & Returns a Map, contains result - rating, pageindex, sent flag.
  static Future<Map?> loadFeedbackForm(String formId) async {
    return await _channel.invokeMethod('loadFeedbackForm', <String, dynamic>{ 'formId': formId });
  }

  /// Load the Passive Form with current screen captured, using formId & Returns a Map, contains result - rating, pageindex, sent flag.
  static Future<Map?> loadFeedbackFormWithCurrentViewScreenshot(String formId) async {
    return await _channel.invokeMethod(
        'loadFeedbackFormWithCurrentViewScreenshot', <String, dynamic>{ 'formId': formId }
        );
  }

  /// Sets filename to look for localization in IOS.
  static Future<void> localizedStringFile(String localizedStringFile) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('loadLocalizedStringFile', <String, dynamic>{
        'localizedStringFile': localizedStringFile,
      });
    } else {
      print('localizedStringFile method only available for IOS');
    }
  }

  /// Loads Passive Forms for offline usage and returns true if loaded successfully.
  static Future<bool?> preloadFeedbackForms(List formIDs) async {
    return await _channel.invokeMethod('preloadFeedbackForms', <String, dynamic>{ 'formIDs': formIDs });
  }

  /// Sets and returns debug state from the SDK.
  static Future<bool?> setDebugEnabled(bool debugEnabled) async {
    return await _channel.invokeMethod('setDebugEnabled', <String, dynamic>{ 'debugEnabled': debugEnabled });
  }
}
