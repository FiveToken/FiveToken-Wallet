import 'package:fil/widgets/random.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test random widget', (tester) async {
    var addr = '0xEa00C8d2d4e658Afc23737181aa1c12F9b99551e';
    await tester.pumpWidget(MaterialApp(
      home: RandomIcon(addr),
    ));
    expect(find.byType(Transform), findsNWidgets(3));
  });
}
