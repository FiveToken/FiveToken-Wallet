import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate isRelease", () async {
    var res = Global.isRelease;
    expect(res, false);
  });
  test("generate info ", () async {
    var res = Global.info;
    expect(res, {});
  });
  test("generate netPrefix", () async {
    var res = Global.netPrefix;
    expect(res, 'f');
  });
}