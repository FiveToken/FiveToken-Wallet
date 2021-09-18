import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test format time by str', () {
    var timestamp = 1631525532;
    var formatStr = '2021-09-13 17:32:12';
    var res = formatTimeByStr(timestamp);
    expect(res, formatStr);
  });
}
