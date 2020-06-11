/// Usabilla Configuration

// Replace appId with your usabilla app id.
const String appId = 'YOUR_APP_ID_HERE';
// Replace FormId with your usabilla form id.
const String formId = 'YOUR_FORM_ID_HERE';

/// To use event from here at sendEvent line #122 at app.dart
/// Change `String event = textFieldController.text;` to `String event = ubConfig.event;`
// Replace event with your usabilla campaign event tag created for targeting specific Campaign.
const String event = 'YOUR_EVENT_TAG_HERE';

// Replace custom variable with your usabilla custom variable created for targeting specific Campaign..
const Map customVariable = {'YOUR_KEY_HERE': 'YOUR_VALUE_HERE'};
