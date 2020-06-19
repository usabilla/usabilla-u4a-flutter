import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usabilla/flutter_usabilla.dart';

class UsabillaDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonColor: Color(0xff00a5c9),
        buttonTheme: ButtonThemeData(
          //  <-- dark color
          textTheme:
              ButtonTextTheme.primary, //  <-- this auto selects the right color
        ),
      ),
      home: Scaffold(
        body: Center(
          child: HomeWidget(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget to display start video call layout.
class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

Widget createButton(btnText, btnMethod) {
  return RaisedButton(
    child: Text(
      btnText,
      style: TextStyle(fontSize: 15),
    ),
    padding: const EdgeInsets.all(15.0),
    textColor: Colors.white,
    color: Color(0xff00a5c9),
    onPressed: btnMethod,
    textTheme: ButtonTextTheme.normal,
  );
}

class _HomeWidgetState extends State<HomeWidget> {
  String os = Platform.operatingSystem;
  String _platformVersion = 'Unknown';
  String _appId = 'YOUR_APP_ID_HERE';
  String _formId = 'YOUR_FORM_ID_HERE';
  String _event = 'YOUR_EVENT_TAG_HERE';
  String _defaultMaskCharacter = 'YOUR_DEFAULT_MASK_CHARACTER_HERE';
  List _defaultDataMask = [];
  List<String> _formIds = [];
  Map customVariable = {'YOUR_KEY_HERE': 'YOUR_VALUE_HERE'};
  String _localizedStringFilename = 'YOUR_LOCALE_FILE_NAME_HERE';

  final textFieldController = TextEditingController();
  bool _validate = false;

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initialize();
//    setDebugEnabled();
//    setCustomVariable();
//    getDefaultData();
//    localizedStringFile();
//    _formIds.add(_formId);
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      print('platformVersion started');
      platformVersion = await FlutterUsabilla.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> initialize() async {
    print('init started');
    try {
      await FlutterUsabilla.initialize(_appId);
    } on PlatformException {
      print('Failed to initialize.');
    }
  }

  Future<void> sendEvent() async {
    print('Send Event clicked');
    Map ubResult;
    String event = textFieldController.text;
    if (event.isNotEmpty) {
      setState(() {
        _validate = false;
      });
      try {
        ubResult = await FlutterUsabilla.sendEvent(event);
      } on PlatformException {
        print('Failed to sendEvent.');
      }
      print('result - $ubResult');
    } else {
      print('Value Can\'t Be Empty');
      setState(() {
        _validate = true;
      });
    }
  }

  Future<void> resetEvents() async {
    print('reset event clicked');
    try {
      await FlutterUsabilla.resetCampaignData();
    } on PlatformException {
      print('Failed to resetCampaignData.');
    }
  }

  Future<void> showForm() async {
    print('show Form clicked');
    Map ubResult;
    try {
      ubResult = await FlutterUsabilla.loadFeedbackForm(_formId);
    } on PlatformException {
      print('Failed to loadFeedbackForm.');
    }
    print('result - $ubResult');
  }

/*
  Future<void> setDebugEnabled() async {
    print('setDebugEnabled started');
    try {
      await FlutterUsabilla.setDebugEnabled(false);
    } on PlatformException {
      print('Failed to setDebugEnabled.');
    }
  }

  Future<void> localizedStringFile() async {
    print('localizedStringFile started');
    try {
      await FlutterUsabilla.localizedStringFile(_localizedStringFilename);
    } on PlatformException {
      print('Failed to localizedStringFile.');
    }
  }

  Future<void> setCustomVariable() async {
    print('custom variable started');
    try {
      await FlutterUsabilla.setCustomVariables(customVariable);
    } on PlatformException {
      print('Failed to get platform version.');
    }
  }

  Future<void> showFormWithScreenshot() async {
    print('show Form clicked');
    Map ubResult;
    try {
      ubResult =
          await FlutterUsabilla.loadFeedbackFormWithCurrentViewScreenshot(
              _formId);
    } on PlatformException {
      print('Failed to loadFeedbackFormWithCurrentViewScreenshot.');
    }
    print('result - $ubResult');
  }

  Future<void> dismiss() async {
    print('dismiss clicked');
    try {
      await FlutterUsabilla.dismiss();
    } on PlatformException {
      print('Failed to dismiss.');
    }
  }

  Future<void> setDataMasking() async {
    print('setDataMasking clicked');
    try {
      await FlutterUsabilla.setDataMasking(
          _defaultDataMask, _defaultMaskCharacter);
    } on PlatformException {
      print('Failed to setDataMasking.');
    }
  }

  Future<void> getDefaultData() async {
    List defaultDataMask;
    try {
      defaultDataMask = await FlutterUsabilla.defaultDataMasks;
    } on PlatformException {
      defaultDataMask = ['Failed to get defaultDataMasks.'];
    }
    setState(() {
      _defaultDataMask = defaultDataMask;
    });
  }

  Future<void> preloadForms() async {
    print('preloadForms clicked $_formId');
    !_formIds.contains(_formId) ?? _formIds.add(_formId);
    try {
      print('preloadForms $_formIds');
      await FlutterUsabilla.preloadFeedbackForms(_formIds);
    } on PlatformException {
      print('Failed to preloadForms.');
    }
  }

  Future<void> removeCachedForms() async {
    print('removeCachedForms clicked');
    try {
      await FlutterUsabilla.removeCachedForms();
    } on PlatformException {
      print('Failed to removeCachedForms.');
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              'images/logo.png',
              width: 200,
            ),
            Icon(
              Icons.add,
              color: Color(0xff00a5c9),
              size: 50.0,
            ),
            FlutterLogo(
              size: 75,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              createButton('Show Form', showForm),
              Container(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: textFieldController,
                      style: TextStyle(height: 0.5, color: Colors.black),
                      decoration: InputDecoration(
                          errorText: _validate ? 'Value Can\'t Be Empty' : null,
                          border: OutlineInputBorder(),
                          hintText: 'Enter Event here'),
                    ),
                  ),
                  createButton('Send Event', sendEvent),
                ],
              ),
              Container(height: 20),
              createButton('Reset', resetEvents),
            ],
          ),
        ),
        Image.asset(
          'images/footer.png',
          width: 100,
        ),
      ],
    );
  }
}
