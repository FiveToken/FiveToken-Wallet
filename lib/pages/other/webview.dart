import 'dart:io';
import 'package:fil/index.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: prefer_collection_literals
// final Set<JavascriptChannel> jsChannels = [
//   JavascriptChannel(
//       name: 'Print',
//       onMessageReceived: (JavascriptMessage message) {
//         print(message.message);
//       }),
// ].toSet();

class WebviewPage extends StatefulWidget {
  @override
  State createState() => WebviewPageState();
}

class WebviewPageState extends State<WebviewPage> {
  bool _showLoading = true;

  Widget _renderLoading(BuildContext context, BoxConstraints constraints) {
    if (!_showLoading) {
      return Positioned(
        child: SizedBox(),
      );
    }
    return Positioned(
      left: 0,
      top: 0,
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    Future.delayed(Duration(milliseconds: 1500)).then((_) {
      setState(() {
        _showLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String selectedUrl = '';
    String title = '';
    if (Global.info[InfoKeyWebUrl] != null) {
      selectedUrl = Global.info[InfoKeyWebUrl];
    }
    if (Global.info[InfoKeyWebTitle] != null) {
      title = Global.info[InfoKeyWebTitle];
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          child: AppBar(
            backgroundColor: Color(FColorWhite),
            elevation: NavElevation,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: IconNavBack,
              alignment: NavLeadingAlign,
            ),
            title: Text(title, style: NavTitleStyle),
            centerTitle: true,
          ),
          preferredSize: Size.fromHeight(NavHeight),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                Opacity(
                  opacity: _showLoading ? 0 : 1,
                  child: Container(
                    child: WebView(
                        initialUrl: selectedUrl,
                        javascriptMode: JavascriptMode.unrestricted),
                  ),
                ),
                _renderLoading(context, constraints),
              ],
            );
          },
        ));
  }
}
