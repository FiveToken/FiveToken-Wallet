import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flotus/flotus.dart';

void main() {
  const MethodChannel channel = MethodChannel('flotus');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Flotus.platformVersion, '42');
  });
}
