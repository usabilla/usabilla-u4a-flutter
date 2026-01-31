import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// FlutterUsabilla flutter wrapper for Usabilla SDK.
class FlutterUsabilla {
  static const MethodChannel _channel = MethodChannel('flutter_usabilla');
  static const EventChannel _eventChannel = EventChannel('flutter_usabilla_events');

  /// Returns a stream of standard events data.
  static Future<Stream<dynamic>> standardEventsData() async {
    return _eventChannel.receiveBroadcastStream();
  }

  /// Gives the current platform version.
  static Future<String?> get platformVersion async {
    return await _channel.invokeMethod<String>('getPlatformVersion');
  }

  /// Manually Dismiss the Forms / Campaign.
  static Future<void> dismiss() async {
    await _channel.invokeMethod<void>('dismiss');
  }

  /// Sets custom variables for targeting Campaigns.
  static Future<void> setCustomVariables(Map<String, String> customVariables) async {
    await _channel.invokeMethod<void>('setCustomVariables', <String, dynamic>{
      'customVariables': customVariables,
    });
  }

  /// Sets data masking with default character / passed single character and based on masks rule.
  static Future<void> setDataMasking(List<String> masks, String character) async {
    await _channel.invokeMethod<void>('setDataMasking', <String, dynamic>{
      'masks': masks,
      'character': character,
    });
  }

  /// Returns masks List to check what is the defined rule.
  static Future<List<dynamic>?> get defaultDataMasks async {
    return await _channel.invokeMethod<List<dynamic>>('getDefaultDataMasks');
  }

  /// Load the Campaign & Returns a Map, contains result - rating, pageindex, sent flag.
  static Future<Map<dynamic, dynamic>?> sendEvent(String event) async {
    return await _channel.invokeMethod<Map<dynamic, dynamic>>('sendEvent', <String, dynamic>{
      'event': event,
    });
  }

  /// Remove cached forms.
  static Future<void> removeCachedForms() async {
    await _channel.invokeMethod<void>('removeCachedForms');
  }

  /// Reset Campaign, so can be triggered from fresh count.
  static Future<void> resetCampaignData() async {
    await _channel.invokeMethod<void>('resetCampaignData');
  }

  /// Initialize the SDK, using appID.
  static Future<void> initialize(String appId) async {
    await _channel.invokeMethod<void>('initialize', <String, dynamic>{
      'appId': appId,
    });
  }

  /// Load the Passive Form, using formId & Returns a Map, contains result - rating, pageindex, sent flag.
  static Future<Map<dynamic, dynamic>?> loadFeedbackForm(String formId) async {
    return await _channel.invokeMethod<Map<dynamic, dynamic>>('loadFeedbackForm', <String, dynamic>{
      'formId': formId,
    });
  }

  /// Load the Passive Form with current screen captured, using formId & Returns a Map, contains result - rating, pageindex, sent flag.
  static Future<Map<dynamic, dynamic>?> loadFeedbackFormWithCurrentViewScreenshot(String formId) async {
    return await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'loadFeedbackFormWithCurrentViewScreenshot',
      <String, dynamic>{
        'formId': formId,
      },
    );
  }

  /// Sets filename to look for localization in iOS.
  static Future<void> localizedStringFile(String localizedStringFile) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('loadLocalizedStringFile', <String, dynamic>{
        'localizedStringFile': localizedStringFile,
      });
    } else {
      // ignore: avoid_print
      print('localizedStringFile method only available for iOS');
    }
  }

  /// Loads Passive Forms for offline usage and returns true if loaded successfully.
  static Future<bool?> preloadFeedbackForms(List<String> formIDs) async {
    return await _channel.invokeMethod<bool>('preloadFeedbackForms', <String, dynamic>{
      'formIDs': formIDs,
    });
  }

  /// Sets and returns debug state from the SDK.
  static Future<bool?> setDebugEnabled(bool debugEnabled) async {
    return await _channel.invokeMethod<bool>('setDebugEnabled', <String, dynamic>{
      'debugEnabled': debugEnabled,
    });
  }

  /// Pre-populates the email component in Usabilla forms or Campaigns.
  /// 
  /// [email] - The email address to pre-populate in the email field.
  /// [editable] - Whether the user can edit the pre-populated email address.
  /// 
  /// Note: If the provided email is in an incorrect format, [editable] will 
  /// always be set to true. The email will be automatically removed once a 
  /// campaign or form closes.
  static Future<void> prePopulateEmailComponent(String email, {bool editable = true}) async {
    await _channel.invokeMethod<void>('prePopulateEmailComponent', <String, dynamic>{
      'email': email,
      'editable': editable,
    });
  }

  /// Sets whether the footer logo is clickable or not.
  static Future<void> setFooterLogoClickable(bool clickable) async {
    await _channel.invokeMethod<void>('setFooterLogoClickable', <String, dynamic>{
      'clickable': clickable,
    });
  }
}
