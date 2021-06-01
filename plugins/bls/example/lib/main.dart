import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:bls/bls.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    String ck, pk, sign;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // ck = await Bls.ckgen(num: "3920719821373211138135206736995243204711509321097422731182236239109116231206197207106180160201722225538951916823619178521471121227156838760767428721010720171184161");
      // pk = await Bls.pkgen(num: ck);
      // sign = await Bls.cksign(num: "$ck 4P//////////gf//////////Dw==");
      ck = "vVgRLxLkDJ4wc64HMnq+FXSIUZ0RCHbrlj2+qWOjBBI=";
      pk = await Bls.pkgen(num: ck);
      sign = await Bls.cksign(num: "$ck dGhpcyBpcyBhIG1lc3NhZ2U=");
      platformVersion = "$ck || $pk || $sign";
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
