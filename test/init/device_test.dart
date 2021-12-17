import 'package:device_info/device_info.dart';
import 'package:fil/init/device.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'device_test.mocks.dart';

@GenerateMocks([
  DeviceInfoPlugin,
  AndroidBuildVersion,
  AndroidDeviceInfo,
  IosDeviceInfo,
])
void main() {
  test("generate init device", () async {
    final mockDeviceInfoPlugin = MockDeviceInfoPlugin();
    final mockAndroidBuildVersion = MockAndroidBuildVersion();
    final _mockIosDeviceInfo = MockIosDeviceInfo();
    when(mockAndroidBuildVersion.baseOS).thenReturn('11');
    when(mockDeviceInfoPlugin.androidInfo).thenAnswer((realInvocation) async =>
        Future.value(AndroidDeviceInfo(
            version: mockAndroidBuildVersion,
            board: "",
            bootloader: '',
            brand: '',
            device: '',
            display: '',
            fingerprint: '',
            hardware: '',
            host: '',
            id: '',
            manufacturer: '',
            model: '',
            product: '',
            supported32BitAbis: [''],
            supported64BitAbis: [''],
            supportedAbis: [''],
            tags: '',
            type: '',
            isPhysicalDevice: false,
            androidId: '22',
            systemFeatures: [''])));
    when(mockAndroidBuildVersion.baseOS).thenReturn('11');

    initDeviceInfo(deviceInfoPlugin:mockDeviceInfoPlugin,isAndroid:true);

    expect((await mockDeviceInfoPlugin.androidInfo).androidId, '22');

    when(mockDeviceInfoPlugin.iosInfo).thenAnswer((realInvocation) async =>
        Future.value(IosDeviceInfo(
          systemName: 'ios',
          systemVersion: '',
          model: '',
          localizedModel: '',
          identifierForVendor: '',
          isPhysicalDevice:false,
        )));
    initDeviceInfo(deviceInfoPlugin:mockDeviceInfoPlugin,isAndroid:false);
    expect((await mockDeviceInfoPlugin.iosInfo).systemName, 'ios');
  });
}
