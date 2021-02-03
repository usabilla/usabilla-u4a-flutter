# flutter_usabilla_example

Demonstrates how to use the flutter_usabilla plugin.

## Getting Started

This project is a starting point for a Flutter application.

### Create Flutter Application
For help getting started with Flutter [online documentation](https://flutter.dev/docs/get-started/install)
or to setup a new app [create new flutter app](https://flutter.dev/docs/get-started/install/macos#create-and-run-a-simple-flutter-app).

### Installation

1. Edit the `pubspec.yaml` file in your `flutter` directory to define the Usabilla SDK dependency:
```yaml
dependencies:
  ...

  flutter_usabilla: ^${latestVersion}
```

2. Run the following command in your terminal after navigating to your project directory, to download the package

```
flutter pub get
```

### Setup SDK
- Import Usabilla Flutter SDK

``` dart
import 'package:flutter_usabilla/flutter_usabilla.dart';
```

-  Update Configurations to run sample app
``` dart
'import "../configuration.dart" as ubConfig;'
```
``` dart
/// Usabilla Configuration
const String appId = 'YOUR_APP_ID_HERE';
const String formId = 'YOUR_FORM_ID_HERE';
const String event = 'YOUR_EVENT_TAG_HERE';
const Map<String, String> customVariable = {'YOUR_KEY_HERE': 'YOUR_VALUE_HERE'};
```

### Functions

- Initialize the sdk.
```
initialize(String appId) → void
```
``` dart
  Future<void> initialize() async {
    try {
      await FlutterUsabilla.initialize('Your_APP_ID');
    } on PlatformException {
      print('Failed to initialize.');
    }
  }
```
- Shows the Passive Form & Returns a Map, contains result - rating, pageindex, sent flag.
```
loadFeedbackForm(String formId) → Future<Map>
```
``` dart
  Future<void> showForm() async {
    Map ubResult;
    try {
      ubResult = await FlutterUsabilla.loadFeedbackForm('Your_FORM_ID');
    } on PlatformException {
      print('Failed to loadFeedbackForm.');
    }
    print('result - $ubResult');
  }
```
- Load the Passive Form with current screen captured & Returns a Map, contains result - rating, pageindex, sent flag.
```
loadFeedbackFormWithCurrentViewScreenshot → Future<Map>
```
``` dart
  Future<void> showFormWithScreenshot() async {
    Map ubResult;
    try {
      ubResult =
          await FlutterUsabilla.loadFeedbackFormWithCurrentViewScreenshot(
              'Your_FORM_ID');
    } on PlatformException {
      print('Failed to loadFeedbackFormWithCurrentViewScreenshot.');
    }
    print('result - $ubResult');
  }
```
- Load the Campaign & Returns a Map, contains result - rating, pageindex, sent flag.
```
sendEvent(String event) → Future<Map>
```
``` dart
  Future<void> sendEvent() async {
    Map ubResult;
      try {
        ubResult = await FlutterUsabilla.sendEvent('YOUR_EVENT_HERE');
      } on PlatformException {
        print('Failed to sendEvent.');
      }
      print('result - $ubResult');
  }
```
- Reset Campaign, so can be triggered from fresh count.
```
resetCampaignData() → void
```
``` dart
  Future<void> resetEvents() async {
    try {
      await FlutterUsabilla.resetCampaignData();
    } on PlatformException {
      print('Failed to resetCampaignData.');
    }
  }
```
- Manually Dismiss the Forms / Campaign.
```
dismiss() → void
```
``` dart
  Future<void> dismiss() async {
    try {
      await FlutterUsabilla.dismiss();
    } on PlatformException {
      print('Failed to dismiss.');
    }
  }
```
- Sets custom variables for targeting Campaigns.
```
setCustomVariables(Map customVariables) → void
```
``` dart
  Map<String, String> customVariable = {'YOUR_KEY_HERE': 'YOUR_VALUE_HERE'};
  Future<void> setCustomVariable() async {
    try {
      await FlutterUsabilla.setCustomVariables(customVariable);
    } on PlatformException {
      print('Failed to get platform version.');
    }
  }
```
- Sets data masking with default character / passed single character and based on masks rule.
```
setDataMasking(List masks, String character) → void
```
``` dart
  Future<void> setDataMasking() async {
    try {
      await FlutterUsabilla.setDataMasking(
          _defaultDataMask, _defaultMaskCharacter);
    } on PlatformException {
      print('Failed to setDataMasking.');
    }
  }
```
- Returns masks List to check what is the defined rule.
```
defaultDataMasks → Future<List>
```
``` dart
  Future<void> getDefaultData() async {
    List defaultDataMask;
    try {
      defaultDataMask = await FlutterUsabilla.defaultDataMasks;
    } on PlatformException {
      defaultDataMask = ['Failed to get defaultDataMasks.'];
    }
     print('result - $defaultDataMask');
  }
```
- Remove cached forms.
```
removeCachedForms() → void
```
``` dart
  Future<void> removeCachedForms() async {
    try {
      await FlutterUsabilla.removeCachedForms();
    } on PlatformException {
      print('Failed to removeCachedForms.');
    }
  }
```
- Sets and returns debug state from the SDK.
```
setDebugEnabled(bool debugEnabled) → Future<bool>
```
``` dart
  Future<void> setDebugEnabled() async {
    try {
      await FlutterUsabilla.setDebugEnabled(false);
    } on PlatformException {
      print('Failed to setDebugEnabled.');
    }
  }
```
- Loads Passive Forms for offline usage and returns true if loaded successfully.
```
preloadFeedbackForms(List formIDs) → Future<bool>
```
``` dart
Future<void> preloadForms() async {
    try {
      await FlutterUsabilla.preloadFeedbackForms(['Your_FORM_ID','Your_FORM_ID','Your_FORM_ID']);
    } on PlatformException {
      print('Failed to preloadForms.');
    }
  }
```
- Sets filename to look for localization in IOS.
```
localizedStringFile(String localizedStringFile) → void
```
``` dart
  Future<void> localizedStringFile() async {
    try {
      await FlutterUsabilla.localizedStringFile('YOUR_LOCALIZED_STRING_FILENAME');
    } on PlatformException {
      print('Failed to localizedStringFile.');
    }
  }
```