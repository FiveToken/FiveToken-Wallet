import 'dart:io';

import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
import 'package:get/get.dart';

void main() async {
  Get.put(StoreController());
  await initHive();
  var initialRoute = await initSharedPreferences();
  runApp(App(initialRoute));
  SystemUiOverlayStyle style =
      SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light);
  SystemChrome.setSystemUIOverlayStyle(style);
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
