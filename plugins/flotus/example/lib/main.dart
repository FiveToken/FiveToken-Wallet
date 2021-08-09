import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flotus/flotus.dart';

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
    String platformVersion, pk, addr, msg, cid;
    // Platform messages may fail, so we use a try/catch PlatformException.
    pk = "jYpwp93MHABEeFfrcDnUo6Hpi0eqEuzARRHVhDRwfkSEd9lhm80EU3Sg+RI28PFu";
    addr = await Flotus.genAddress(pk: pk, t: "secp");
    msg = """
      {
        "Version": 0,
        "To": "f125p5nhte6kwrigoxrcaxftwpinlgspfnqd2zaui",
        "From": "f153zbrv25wvfrqf2vrvlk2qmpietuu6wexiyerja",
        "Nonce": 0,
        "Value": "10000000000000000000",
        "GasLimit": 1000000000000,
        "GasFeeCap": "10000000",
        "GasPremium": "10000000",
        "Method": 0,
        "Params": ""
      }
      """;
    cid = await Flotus.messageCid(msg: msg);

    var prk = await Flotus.secpPrivateToPublic(ck: "67WMRDA2ldmfcQ87DSHCy+ppKs3iSyNjxfBD7dR68Qw=");
    var sig = await Flotus.secpSign(ck: "67WMRDA2ldmfcQ87DSHCy+ppKs3iSyNjxfBD7dR68Qw=", msg: "AXGg5AIgA7aUiB+WKlJZi77CrBo4OgwytRmXbBXj8ratzAtshGM=");
    platformVersion = "$addr -- $cid : \n$prk \n $sig";
    
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
