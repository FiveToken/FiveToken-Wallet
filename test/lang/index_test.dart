import 'package:fil/lang/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/lang/en.dart';
import 'package:fil/lang/jp.dart';
import 'package:fil/lang/kr.dart';
import 'package:fil/lang/zh.dart';
void main() {
  test("generate config connectTimeout", () async {
    Map<String, Map<String, String>> keys = {
      'en': EN_LANG, 'zh': ZH_LANG, 'jp': JP_LANG, 'kr': KR_LANG
    };
    var msg = new Messages();
    Map<String, Map<String, String>> res = msg.keys;
    expect(res, keys);
  });
}