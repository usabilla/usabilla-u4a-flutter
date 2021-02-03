import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart' as ubConst;
import "../configuration.dart" as ubConfig;
import 'package:flutter_usabilla/flutter_usabilla.dart';

class UsabillaDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: HomeWidget(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

Widget createButton(btnText, btnMethod) {
  return SizedBox(
    height: 48.0,
    child: RaisedButton(
      child: Text(
        btnText,
        style: TextStyle(
          fontSize: 19.0,
          fontFamily: 'MiloOT-Medi',
        ),
      ),
      padding: const EdgeInsets.all(15.0),
      textColor: Colors.white,
      color: ubConst.colorUb,
      onPressed: btnMethod,
      textTheme: ButtonTextTheme.normal,
    ),
  );
}

Widget createEventButton(btnText, btnMethod) {
  return SizedBox(
    height: 48.0,
    child: RaisedButton(
      child: Text(
        btnText,
        style: TextStyle(
          fontSize: 19.0,
          fontFamily: 'MiloOT-Medi',
        ),
      ),
      textColor: ubConst.colorUb,
      color: Colors.white,
      onPressed: btnMethod,
      textTheme: ButtonTextTheme.normal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
        side: BorderSide(
          color: ubConst.colorUb,
        ),
      ),
    ),
  );
}

class _HomeWidgetState extends State<HomeWidget> {
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
    initialize();
    setCustomVariable();
  }

  /// Initialize SDK
  Future<void> initialize() async {
    print('init started');
    try {
      await FlutterUsabilla.initialize(ubConfig.appId);
    } on PlatformException {
      print('Failed to initialize.');
    }
  }

  /// sets custom variable used to show Campaign
  Future<void> setCustomVariable() async {
    print('custom variable started');
    try {
      await FlutterUsabilla.setCustomVariables(ubConfig.customVariable);
    } on PlatformException catch (err){
      print(err);
    }
  }

  /// Shows Active form / Campaign
  Future<void> sendEvent() async {
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
      setState(() {
        _validate = true;
      });
    }
  }

  /// Reset Active form / Campaign
  /// Do reset once a Campaign is already shown
  Future<void> resetEvents() async {
    try {
      await FlutterUsabilla.resetCampaignData();
    } on PlatformException {
      print('Failed to resetCampaignData.');
    }
  }

  /// Shows Passive form
  Future<void> showForm() async {
    Map ubResult;
    try {
      ubResult = await FlutterUsabilla.loadFeedbackForm(ubConfig.formId);
    } on PlatformException {
      print('Failed to loadFeedbackForm.');
    }
    print('result - $ubResult');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(40.0, 60.0, 0.0, 0.0),
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  ubConst.headerString,
                  style: TextStyle(
                    fontSize: 55.0,
                    fontFamily: 'MiloOT-Bold',
                    color: ubConst.colorUb,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              createButton(ubConst.showFormBtnText, showForm),
              Container(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 48.0,
                      width: 193.0,
                      child: TextField(
                        controller: textFieldController,
                        style: TextStyle(
                            fontSize: 19.0,
                            fontFamily: 'MiloOT',
                            height: 1.0,
                            color: Colors.black),
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            errorText:
                                _validate ? ubConst.sendEventErrorText : null,
                            border: OutlineInputBorder(),
                            hintText: ubConst.sendEventPlaceholder),
                      ),
                    ),
                  ),
                  Container(width: 16.0),
                  createEventButton(ubConst.sendEventBtnText, sendEvent),
                ],
              ),
              Container(height: 16.0),
              createEventButton(ubConst.resetBtnText, resetEvents),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
          child: Image.asset(
            'assets/images/footer.png',
            width: 100,
          ),
        ),
      ],
    );
  }
}
