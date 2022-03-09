import 'dart:math';
import 'dart:typed_data';
import 'package:fil/utils/num_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/utils/decimal_extension.dart';

void main() {
  String amount = '12345678901234567890';
  var res1 = '1234567890.1234';
  test("generate utils fmtDown ", () async {
    var _amount = double.parse(amount)/pow(10, 10);
    var _decimal = _amount.toDecimal;
    var res = _decimal.fmtDown(4);
    print(res);
    expect(res, res1);
  });
  test("generate utils fmtUp ", () async {
    var _amount = double.parse(amount)/pow(10, 10);
    var _decimal = _amount.toDecimal;
    var res = _decimal.fmtUp(4);
    print(res);
    expect(res, res1);
  });
  test("generate utils Uint8ListExtension", (){
    Uint8List list = Uint8List(12);
    String res1 = "AAAAAAAAAAAAAAAA";
    expect(list.toEncode(), res1);
  });
}