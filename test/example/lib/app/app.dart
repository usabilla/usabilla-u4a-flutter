import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart' as ub_const;
import '../configuration.dart' as ub_config;
import 'package:flutter_usabilla/flutter_usabilla.dart';

class UsabillaDemoApp extends StatelessWidget {
  const UsabillaDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const HomeWidget(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

Widget createButton(String btnText, VoidCallback? btnMethod) {
  return SizedBox(
    height: 48.0,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: ub_const.colorUb,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(15.0),
        textStyle: const TextStyle(
          fontSize: 19.0,
          fontFamily: 'MiloOT-Medi',
        ),
      ),
      onPressed: btnMethod,
      child: Text(btnText),
    ),
  );
}

Widget createEventButton(String btnText, VoidCallback? btnMethod) {
  return SizedBox(
    height: 48.0,
    child: ElevatedButton(
      onPressed: btnMethod,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: ub_const.colorUb,
        textStyle: const TextStyle(
          fontSize: 19.0,
          fontFamily: 'MiloOT-Medi',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1.0),
          side: const BorderSide(color: ub_const.colorUb),
        ),
      ),
      child: Text(btnText),
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
    FlutterUsabilla.setDebugEnabled(true);
  }

  /// Initialize SDK
  Future<void> initialize() async {
    debugPrint('init started');
    try {
      await FlutterUsabilla.initialize(ub_config.appId);
      standardEventsData();
    } on PlatformException {
      debugPrint('Failed to initialize.');
    }
  }

  /// sets custom variable used to show Campaign
  Future<void> setCustomVariable() async {
    debugPrint('custom variable started');
    try {
      await FlutterUsabilla.setCustomVariables(ub_config.customVariable);
    } on PlatformException catch (err) {
      debugPrint(err.toString());
    }
  }

  /// Shows Active form / Campaign
  Future<void> sendEvent() async {
    Map<dynamic, dynamic>? ubResult;
    String event = textFieldController.text;
    if (event.isNotEmpty) {
      setState(() {
        _validate = false;
      });
      try {
        ubResult = await FlutterUsabilla.sendEvent(event);
      } on PlatformException {
        debugPrint('Failed to sendEvent.');
      }
      debugPrint('result - $ubResult');
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  Future<void> standardEventsData() async {
    try {
      Stream<dynamic> stream = await FlutterUsabilla.standardEventsData();
      stream.listen(_onData, onError: _onErrorData);
    } on PlatformException {
      debugPrint('Failed to get standardEventsData.');
    }
  }

  static void _onData(dynamic event) {
    debugPrint('response : $event');
  }

  static void _onErrorData(dynamic error) {
    debugPrint('error: $error');
  }

  /// Reset Active form / Campaign
  /// Do reset once a Campaign is already shown
  Future<void> resetEvents() async {
    try {
      await FlutterUsabilla.resetCampaignData();
    } on PlatformException {
      debugPrint('Failed to resetCampaignData.');
    }
  }

  /// Shows Passive form
  Future<void> showForm() async {
    Map<dynamic, dynamic>? ubResult;
    try {
      ubResult = await FlutterUsabilla.loadFeedbackFormWithCurrentViewScreenshot(
        ub_config.formId,
      );
    } on PlatformException {
      debugPrint('Failed to loadFeedbackForm.');
    }
    debugPrint('result - $ubResult');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 60.0, 0.0, 0.0),
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  ub_const.headerString,
                  style: const TextStyle(
                    fontSize: 55.0,
                    fontFamily: 'MiloOT-Bold',
                    color: ub_const.colorUb,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              createButton(ub_const.showFormBtnText, showForm),
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 48.0,
                      width: 193.0,
                      child: TextField(
                        controller: textFieldController,
                        style: const TextStyle(
                          fontSize: 19.0,
                          fontFamily: 'MiloOT',
                          height: 1.0,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          errorText: _validate ? ub_const.sendEventErrorText : null,
                          border: const OutlineInputBorder(),
                          hintText: ub_const.sendEventPlaceholder,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  createEventButton(ub_const.sendEventBtnText, sendEvent),
                ],
              ),
              const SizedBox(height: 16.0),
              createEventButton(ub_const.resetBtnText, resetEvents),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
          child: Image.asset(
            'assets/images/footer.png',
            width: 100,
          ),
        ),
      ],
    );
  }
}
