import 'dart:async';
import 'package:flutter/services.dart';

class FlutterUsabilla {
  static const MethodChannel _channel = const MethodChannel('flutter_usabilla');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> dismiss() async {
    await _channel.invokeMethod('dismiss');
  }

  static Future<void> setCustomVariables(Map customVariables) async {
    await _channel.invokeMethod('setCustomVariables', <String, dynamic>{
      'customVariables': customVariables,
    });
  }

  static Future<void> setDataMasking(List masks, String character) async {
    await _channel.invokeMethod('setDataMasking',
        <String, dynamic>{'masks': masks, 'character': character});
  }

  static Future<List> get defaultDataMasks async {
    final List defaultDataMask =
        await _channel.invokeMethod('getDefaultDataMasks');
    return defaultDataMask;
  }

  static Future<Map> sendEvent(String event) async {
    final Map ubResult =
        await _channel.invokeMethod('sendEvent', <String, dynamic>{
      'event': event,
    });
    return ubResult;
  }

  static Future<void> removeCachedForms() async {
    await _channel.invokeMethod('removeCachedForms');
  }

  static Future<void> resetCampaignData() async {
    await _channel.invokeMethod('resetCampaignData');
  }

  static Future<void> initialize(String appId) async {
    await _channel.invokeMethod('initialize', <String, dynamic>{
      'appId': appId,
    });
  }

  static Future<Map> loadFeedbackForm(String formId) async {
    final Map ubFormResult =
        await _channel.invokeMethod('loadFeedbackForm', <String, dynamic>{
      'formId': formId,
    });
    return ubFormResult;
  }

  static Future<Map> loadFeedbackFormWithCurrentViewScreenshot(
      String formId) async {
    final Map ubFormResultWithImage = await _channel.invokeMethod(
        'loadFeedbackFormWithCurrentViewScreenshot', <String, dynamic>{
      'formId': formId,
    });
    return ubFormResultWithImage;
  }

  static Future<void> localizedStringFile(String localizedStringFile) async {
    await _channel.invokeMethod('loadLocalizedStringFile', <String, dynamic>{
      'localizedStringFile': localizedStringFile,
    });
  }
}
