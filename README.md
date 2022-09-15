# Usabilla for Apps - Flutter [![pub package](https://img.shields.io/pub/v/flutter_usabilla.svg)](https://pub.dartlang.org/packages/flutter_usabilla)

Usabilla for Apps allows you to collect feedback from your users with great ease and flexibility.
This Flutter bridge to the Native Usabilla SDK allows you to load passive feedback forms and submit results from a Flutter Apps.
This release uses the Usabilla SDK for `iOS` v6.x.x and `Android` v7.x.x.
Please follow these steps.

- [Usabilla for Apps - Flutter](#usabilla-for-apps---flutter)
  - [Requirements](#requirements)
  - [Installation](#installation)
    - [Setup SDK](#sdk)
    - [iOS](#ios)
    - [Android](#android)
  - [Campaigns](#campaigns)
    - [The App Id](#the-app-id)
    - [Events](#events)
    - [Standard Events](#stnadard-events)
    - [Campaign submission callback](#campaign-submission-callback)
    - [Reset Campaign data](#reset-campaign-data)
    - [Managing an existing Campaign](#managing-an-existing-campaign)
    - [Campaign results](#campaign-results)
  - [Feedback Form](#feedback-form)
    - [The Form ID](#the-form-id)
    - [Screenshot](#screenshot)
    - [Submit the results of the form](#submit-the-results-of-the-form)
    - [Feedback submission callback](#feedback-submission-callback)
  - [Custom Variables](#custom-variables)
  - [Support](#support)

## Requirements

This version of the flutter native bridge / wrapper works with the latest release of `XCode 11`.

## Installation

1. Edit the `pubspec.yaml` file in your `flutter` directory to define the Usabilla
SDK dependency:
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
Import Usabilla Flutter SDK
```
import 'package:flutter_usabilla/flutter_usabilla.dart';
```

### iOS

To use the Usabilla Flutter Plugin on iOS devices, install **Usabilla SDK for iOS** 
to make it an available resource for the Flutter library.
This release uses the Usabilla SDK v6.4.7.

1. Open your iOS project `Runner.xcodeproj` with **Xcode**.
2. Add `Privacy - Camera Usage Description` and `Privacy - Photo Library Usage Description` into **Info.plist**.
```
	<key>NSCameraUsageDescription</key>
	<string>TEXT_FOR_END_USER</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>TEXT_FOR_END_USER</string>
```
3. Set the `iOS Deployment Target` to 9.0 or above
4. Uncomment or add `platform :ios, '9.0'` to the `podfile`.
``` Swift
# Uncomment this line to define a global platform for your project
 platform :ios, '9.0'
```

Run Flutter App.
Incase it fails for pods than fetching of latest Usabilla SDK can be done by updating the pod. This can be done with the following command:
```
pod --repo-update install
```

### Android

1. Make sure that your `MainActivity` extends `FlutterFragmentActivity`
``` Kotlin
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
```
2. Add `minSdkVersion`**:**`19` into `app's build.gradle`
```
    defaultConfig {
        minSdkVersion 19
    }
```
3. Add `Base Application Theme`**:**`AppTheme` into `Application's res/values/styles.xml`
```xml
  <!-- Base application theme. -->
    <style name="AppTheme" parent="Theme.AppCompat.Light.NoActionBar">
        <!-- Customize your theme here. -->
    </style>
```
4. Add `Application Theme`**:**`AppTheme` into `Application's AndroidManifest.xml`
```xml
  <application
        <activity
            android:theme="@style/AppTheme">
```

## Campaigns

In the Usabilla for Apps Platform, a campaign is defined as a proactive survey targeted to a specific set of users.

Being able to run campaigns in your mobile app is great because it allows you to collect more specific insights from your targeted users. What is even better is that creating new and managing existing campaigns can be done without the need for a new release of your app. Everything can be managed from the Usabilla web interface.

You can run as many campaigns as you like and target them to be triggered when a specific set of targeting options are met.
The configuration of how a campaign is displayed to the user will be familiar to existing Usabilla customers. You can configure it to suit your needs just like you are used to from the Passive feedback forms.

The most important aspect of running a mobile campaign is 'Events'. Events are custom triggers that are configured in the SDK. When a pre-defined event occurs, it will allow you to trigger a campaign. A good example of an event is a successful purchase by a user in your app.

### The App Id

The app Id is an identifier used to associate campaigns to a mobile app.
By loading the SDK with a specific app Id, it will fetch all the campaigns connected to the given app Id.

It is possible to target a campaign to more than one app (e.g. iOS Production App, iOS Beta App) by associating it with multiple App Ids.

To run campaigns in your app, you should first start by initializing the SDK and define the App ID that is generated in [Usabilla](https://app.usabilla.com/member/live/apps/campaigns/add):

`FlutterUsabilla.initialize("YOUR_APP_ID")`

This call loads and updates all your campaigns locally and you can start targeting them by sending events from your app.

### Events

Campaigns are triggered by events. Events are used to communicate with the SDK when something happens in your app. Consequently, the SDK will react to an event depending on the configuration of the Usabilla web interface.
To send an event to the SDK, use :

`FlutterUsabilla.sendEvent("YOUR_EVENT_NAME")`

There are multiple options which allow you to define more specific targeting rules of a campaign:
- You can set the number of times an event has to occur (e.g. 3 times).
- Specify the percentage of users for whom the campaign should be triggered (e.g. 10%).
- Define whether you would like to target a specific device language.

It is also possible to segment your user base using **Custom Variables**. **Custom Variables** can be used to specify some traits of the user and target the campaign only to a specific subset.

For more on how to use custom variables, have a look at [Custom Variables](#custom-variables).

**Note: A campaign will never be triggered for the same user more than once.**

### Standard Events

From **`v2.2.1`** onwards we are introducing a new feature **Standard Events**.

**Note : Now with Standard Events you can show campaigns in your application(Host application embedded with GetFeedback Digital/ Usabilla SDK) without adding any extra lines of code. You just have to create Standard Campaigns(Campaigns with Default/System Events) with your `User-Account` at `GetFeedback`.**

Currently we are supporting these lifecycle / system events : 
 - `LAUNCH` : Define as when the app is entering foreground
 - `EXIT` : Define as when the app is entering to the background
 - `CRASH` : Define as when the app is crashed ( terminated due to an unexpected behaviour)

**Note : SDK will not listen to any Default / System events, until it has been initialised and it is recommended to initialise only once. In order to make this work properly, SDK has to be initialize using `FlutterUsabilla.initialize` at the earliest possibility, preferably in the initState method:**

To get some additional information about the response left by your user, you have the option to use the `callback` method. This is a listener that listens in to the moment a Campaign with standard events is closed.

```
  Future<void> standardEventsData() async {
    Stream stream;
    try {
      stream = await FlutterUsabilla.standardEventsData();
      stream.listen(_onData, onError: _onErrorData);
    } on PlatformException {
      print('Failed to get standardEventsData.');
    }
  }
  
  static void _onData(event) {
    print('response : $event');
  }

  static void _onErrorData(error) {
    print('error: $error');
  }
```

[Click here](https://support.usabilla.com/hc/en-us/articles/4747575452562) to read more about Standard Events.

### Campaign submission callback

To get some additional information about the response left by your user, you have the option to use the `callback` method. This is a listener that listens in to the moment a Campaign is closed.

```
  Future<void> sendEvent() async {
    Map response;
    try {
      response = await FlutterUsabilla.sendEvent(_event);
    } on PlatformException {
      print('Failed to sendEvent.');
    }
  }
```
**Android**:
```
/**
 * response {
 *  rating: int,
 *  sent: boolean,
 *  abandonedpageindex: int
 *  }
 */
 ```
 
The **response** object contains the following information:
**rating**: this value contains the response to the Mood/Star rating question.
**sent**: this is flag which determines whether a response is submitted to server or not.
**abandonedpageindex**: this value is set if the user Campaign is closed before submission.

**iOS**:
```
/**
 * response {
 *  result: {
 *  rating: int,
 *  sent: boolean,
 *  abandonedpageindex: int
 *  },
 * isRedirectToAppStoreEnabled: boolean
 * }
 */
```
The **response** object contains the following information:
**result**: this object contains the result.
  **rating**: this value contains the response to the Mood/Star rating question.
  **sent**: this is flag which determines whether a response is submitted to server or not.
  **abandonedpageindex**: this value is set if the user Campaign is closed before submission.
**isRedirectToAppStoreEnabled**: defining a value will enable the App Store Rating prompt.

**NOTE**: **isRedirectToAppStoreEnabled** is not included in the **response** array on Android since displaying the Play Store Rating prompt is handled automatically by the SDK.

### Reset Campaign data

This specific method allows you to reset all the Campaign data. This can be helpful in the implementation process where you would like trigger the same Campaign multiple times. By default this wouldn't be possible since a Campaign will only be triggered once for each user. Resetting the Campaign data can be done by calling the following method.

`FlutterUsabilla.resetCampaignData()`

### Managing an existing Campaign

You can start collecting campaign results right after you create a new campaign in the Usabilla for Apps [Campaign Editor](https://app.usabilla.com/member/live/apps/campaigns/add).
By default, new campaigns are marked as inactive. On the Usabilla for Apps [Campaign Overview](https://app.usabilla.com/member/#/apps/campaigns/overview/) page, you can activate or deactivate an existing campaign at any moment to reflect your specific needs.

Moreover, you can update the content of your campaign (e.g. questions) at any time. Keep in mind that the changes you make to an existing active campaign might affect the integrity of the data you collect (different responses before and after a change).

Furthermore, you can also change the targeting options of a campaign. Keep in mind that updating the targeting options of an active campaign will reset any progression previously made on the user's device.

### Campaign results

Aggregated campaign results are available for download from the [Campaign Overview](https://app.usabilla.com/member/#/apps/campaigns/overview/). Here you can download the results per campaign, in the CSV format.

Campaign results will contain the answers that your users provided. Responses from a campaign are collected and sent to Usabilla page by page. This means that even if a user decides to abandon the campaign halfway through, you will still collect valuable insights. When a user continues to the next page, then the results of the previous page are submitted to Usabilla. Besides campaign results showing the answers to your campaign questions, you will be able to view the device metadata and custom variables.

As for campaign results. Please note that editing the form of an existing campaign will affect the aggregated campaign results:

- Adding new questions to a form will add additional columns to the CSV file.
- Removing questions from an existing form will not affect the previously collected results. The associated column and its data will still be in the CSV file.
- Replacing the question type with a different question is also possible. When you give the same 'name' in the Usabilla for Apps Campaign Editor, then results are represented in the same column.

## Feedback Form

Feedback forms that are Forms that are created in [Usabilla](https://app.usabilla.com/member/#/apps/setup). These are not triggered by events. They are mostly, but not necessarily, initiated by the user.

### The Form ID

Implementing a Feedback Form is done by configuring the Form ID that is generated when a Feedback Form is created in [Usabilla](https://app.usabilla.com/member/apps/list).

In order to load a Passive Feedback form with the Usabilla library you need to call:

`FlutterUsabilla.loadFeedbackForm("YOUR_FORM_ID_HERE")`

### Screenshot

The Screenshot feature can be enabled in the **Advanced Settings** of your Form. By default, users will have the option to either attach a **Photo** or a **Screenshot** to the Feedback item. However, it's also possible to create a **Screenshot** when the user opens the Feedback Form. The method below will take a screenshot of the current visible view and attach it to the Form:

`usabilla.loadFeedbackFormWithCurrentViewScreenshot("YOUR_FORM_ID_HERE")`

### Submit the results of the form

This functionality is embedded in the native Usabilla library and there is no need to perform any specific action from the Flutter environment.

### Feedback submission callback

To get some additional information about the response left by your user, you have the option to use the `callback` method. This is a listener that listens in to the moment the Form is closed.

```
  Future<void> showForm() async {
    Map response;
    try {
      response = await FlutterUsabilla.loadFeedbackForm(_formId);
    } on PlatformException {
      print('Failed to loadFeedbackForm.');
    }
  }
```
**Android**:
```
/**
 * response {
 *  rating: int,
 *  sent: boolean,
 *  abandonedpageindex: int
 * }
 */
```

The **response** array contains the following information:
**rating**: this value contains the response to the Mood/Star rating question.
**sent**: this is flag which determines whether a response is submitted to server or not.
**abandonedpageindex**: this value is set if the user Campaign is closed before submission.

**iOS**:
```
/**
 * response {
 *  results: [{
 *  rating: int,
 *  sent: boolean,
 *  abandonedpageindex: int
 *  }],
 * formId: String,
 * isRedirectToAppStoreEnabled: boolean
 * }
 */
```

The **response** object contains the following information:
**results**: this array contains the result at first index.
  **rating**: this value contains the response to the Mood/Star rating question.
  **sent**: this is flag which determines whether a response is submitted to server or not.
  **abandonedpageindex**: this value is set if the user Campaign is closed before submission.
**isRedirectToAppStoreEnabled**: defining a value will enable the App Store Rating prompt.
**formId**: returns formId.

**NOTE**: **isRedirectToAppStoreEnabled** is not included in the **response** array on Android since displaying the Play Store Rating prompt is handled automatically by the SDK.

## Custom Variables

In order to set custom variables in the Usabilla native library it's necessary to call the method:

`FlutterUsabilla.setCustomVariables(customVariable)`

This method accepts as parameter a valid JSON object with two limitations:
```Map<String,String> customVariable = {'test': '1'};```
Trying to set an invalid object/ Map as a custom variable will result in that object not being set and in an error being printed in the console.

Custom variables are added as extra feedback data with every feedback item sent by the SDK, whether from a passive feedback or a campaign.

**NOTE**: Custom variables can be used as targeting options, as long as the key,value are String type.

## Support

If you require help with the implementation, want to report an issue, or have a question please reach out to our Support Team via support@usabilla.com. When contacting our Support Team please make sure you include your Usabilla Account Name and the name of your Customer Success Manager.
