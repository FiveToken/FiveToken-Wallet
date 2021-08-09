import 'package:fil/index.dart';
import 'package:flutter/services.dart';
class AndroidBackTop {
	//初始化通信管道-设置退出到手机桌面
	static const String CHANNEL = "android/back/desktop";
	//设置回退到手机桌面
	static Future<bool> backDeskTop() async {
		final platform = MethodChannel(CHANNEL);
		//通知安卓返回,到手机桌面
		try {
			await platform.invokeMethod('backDesktop');
		} on PlatformException catch (e) {
			print(e.toString());
		}
		return Future.value(false);
	}
}