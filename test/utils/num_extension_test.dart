import 'package:fil/pages/transfer/transfer.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/utils/num_extension.dart';

void main() {
  var num1 = 1234567890;
  var res1 = 1234567890.0;
  test("generate enum_extension roundUp ", () async {
    var res = num1.roundUp(5);
    print(res);
    expect(res, res1);
  });
}