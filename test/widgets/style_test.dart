import 'package:fil/index.dart';
import 'package:fil/widgets/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate config connectTimeout", () async {
    final cr = CustomRadius();
    BorderRadius b2 = CustomRadius.b2;
    BorderRadius b4 = CustomRadius.b4;
    BorderRadius top = CustomRadius.top;
    BorderRadius crb = cr.border(12.34);
    expect(b2,BorderRadius.circular(6.0));
    expect(b4,BorderRadius.circular(6.0));
    expect(top,BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)));
    expect(crb,BorderRadius.circular(12.34));
  });
}