import 'package:flutter/services.dart';
class AndroidBackTop {
	static const String CHANNEL = "android/back/desktop";
	static Future<bool> backDeskTop() async {
		final platform = MethodChannel(CHANNEL);
		try {
			await platform.invokeMethod('backDesktop');
		} on PlatformException catch (e) {
			print(e.toString());
		}
		return Future.value(false);
	}
}