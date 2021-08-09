import 'package:fil/index.dart';
import 'package:flutter/material.dart';

import './policy/en.dart';
import './policy/zh.dart';
import 'package:webview_flutter/webview_flutter.dart';

final htmlStart = """
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      <style>
        body {
          color: #333333;
          font-size: 14px;
          line-height: 1.4;
          position: relative;
          background-color: #fff;
          min-height: 100vh;
          padding: 15px;
        }
        
        .p-title {
          font-size: 15px;
          font-weight: 555;
          text-align: center;
          margin-bottom: 20px;
        }
        .p-s-title {
          font-size: 14px;
          font-weight: 555;
          margin-bottom: 15px;
          margin-top: 10px;
        }
        .p-text {
          font-size: 14px;
          line-height: 1.4;
          padding-bottom: 15px;
        }
        p {
          color: #333333;
          line-height: 1.6;
          margin-bottom: 10px;
          margin-top: 0;
        }
        h1 {
          color: #333333;
          margin-top: 0;
          margin-bottom: 20px;
        }
        h2 {
          color: #333333;
          padding-top: 5px;
          margin-bottom: 15px;
        }
        h3 {
          color: #333333;
          padding-top: 0px;
          margin-bottom: 10px;
        }
      </style>
    </head>
    <body>
""";
final htmlEnd = """
    </body>
  </html>
""";

class ServicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ServicePageState();
  }
}

class ServicePageState extends State<ServicePage> {
  String selectedUrl = "";
  void _getPolicy() {
    var policy = Global.langCode != 'zh' ? EnPolicy : ZhPolicy;
    String html = "$htmlStart$policy$htmlEnd";
    setState(() {
      selectedUrl = Uri.dataFromString(html,
              mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
          .toString();
    });
  }

  @override
  void initState() {
    super.initState();

    _getPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'service'.tr,
      hasFooter: false,
      body: WebView(
        initialUrl: selectedUrl,
      ),
    );
  }
}
