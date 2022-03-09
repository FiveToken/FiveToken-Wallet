import 'dart:io' show Platform;
import 'package:device_info/device_info.dart';
import 'package:fil/common/global.dart';

Future initDeviceInfo({DeviceInfoPlugin deviceInfoPlugin,bool isAndroid}) async {
  DeviceInfoPlugin _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();
  bool _isAndroid = isAndroid ?? Platform.isAndroid;
  if (_isAndroid) {
    var info = await _deviceInfoPlugin.androidInfo;
    Global.uuid = info.androidId;
    Global.platform = 'android';
    Global.os = info.version.baseOS;
  } else {
    var info = await _deviceInfoPlugin.iosInfo;
    Global.uuid = info.identifierForVendor;
    Global.platform = 'ios';
    Global.os = info.systemVersion.toString();
  }
}
