import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_usabilla/flutter_usabilla.dart';

class UsabillaDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Usabilla Demo'),
        ),
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

class _HomeWidgetState extends State<HomeWidget> {
  String os = Platform.operatingSystem;
  String _platformVersion = 'Unknown';
  String _appId = 'YOUR_APP_ID_HERE';
  String _formId = 'YOUR_FORM_ID_HERE';
  String _event = 'YOUR_EVENT_TAG_HERE';
  String _defaultMaskCharacter = 'YOUR_DEFAULT_MASK_CHARACTER_HERE';
  List _defaultDataMask = [];
  Map customVariable = {'YOUR_KEY_HERE': 'YOUR_VALUE_HERE'};

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initialize();
    setCustomVariable();
    getDefaultData();
  }

  Future<void> setCustomVariable() async {
    print('custom variable started');
    try {
      await FlutterUsabilla.setCustomVariables(customVariable);
    } on PlatformException {
      print('Failed to get platform version.');
    }
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

  Future<void> sendEvent() async {
    print('send event clicked');
    Map ubResult;
    try {
      ubResult = await FlutterUsabilla.sendEvent(_event);
    } on PlatformException {
      print('Failed to sendEvent.');
    }
    print('result - $ubResult');
  }

  Future<void> resetEvents() async {
    print('reset event clicked');
    try {
      await FlutterUsabilla.resetCampaignData();
    } on PlatformException {
      print('Failed to resetCampaignData.');
    }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InfoTitle(
          title: "$os - v$_platformVersion",
        ),
        InfoTitle(
          title: _defaultDataMask.toString(),
        ),
        RaisedButton(
          child: Text('Show Form'),
          onPressed: showForm,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text('Show Form With Screenshot'),
          onPressed: showFormWithScreenshot,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text('Dismiss'),
          onPressed: dismiss,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text('Send Event'),
          onPressed: sendEvent,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text('Reset'),
          onPressed: resetEvents,
          textTheme: ButtonTextTheme.accent,
        ),
        RaisedButton(
          child: Text('setDataMasking'),
          onPressed: setDataMasking,
          textTheme: ButtonTextTheme.accent,
        ),
      ],
    );
  }
}

class InfoTitle extends StatelessWidget {
  InfoTitle({this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          'Running on: $title\n',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
