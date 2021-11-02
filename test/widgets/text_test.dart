import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  var text = WalletLabel;

  testWidgets("test common text main", (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CommonText.main(text),
    ));
    Text t = tester.firstWidget(find.text(text));
    expect(t.style.color, equals(Colors.black));
  });
  testWidgets("test common text grey", (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CommonText.grey(text),
    ));
    Text t = tester.firstWidget(find.text(text));
    expect(t.style.color, equals(CustomColor.grey));
  });
  testWidgets("test common text white", (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CommonText.white(text),
    ));
    Text t = tester.firstWidget(find.text(text));
    expect(t.style.color, equals(Colors.white));
  });
  testWidgets("test common text center", (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CommonText.center(text),
    ));
    Text t = tester.firstWidget(find.text(text));
    expect(t.textAlign, equals(TextAlign.center));
  });
}
