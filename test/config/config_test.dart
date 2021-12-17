import 'package:fil/config/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate config connectTimeout", () async {
    var connectTimeout = Config.connectTimeout;
    expect(connectTimeout, 1000 * 300);
  });
  test("generate config receiveTimeout", () async {
    var receiveTimeout = Config.receiveTimeout;
    expect(receiveTimeout, 1000 * 300);
  });
}