import 'package:fil/pages/create/warn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test render warn page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CreateWarnPage(),
    ));
    expect(find.byType(TipItem), findsNWidgets(3));
    Image image = tester.firstWidget(find.byType(Image));
    expect(image.width, 86.0);
  });
}
