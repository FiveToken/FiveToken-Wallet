import 'package:fil/common/time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate time", () async {
    var str = await formatTimeByStr(1639018100);
    print(str);
    expect(str, equals('2021-12-09 10:48:20'));
  });
}