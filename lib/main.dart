import 'dart:io';
import 'package:fil/store/store.dart' show StoreController;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/app.dart';
import 'package:fil/init/prefer.dart' show initSharedPreferences;
import 'package:fil/request/filecoin.dart';
import 'common/shared_preferences.dart';

void main() async {
  // init store status
  Get.put(StoreController());
  // init hive
  await initHive();
  // init PreferencesManager
  await PreferencesManager.init();
  // init route of pages
  var initRoute = await initSharedPreferences();
  // get api url
  await fetchPing();
  runApp(App(initRoute));
  SystemUiOverlayStyle style = SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light);
  SystemChrome.setSystemUIOverlayStyle(style);
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
