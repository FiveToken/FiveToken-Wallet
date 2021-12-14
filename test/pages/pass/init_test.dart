import 'package:fil/pages/pass/init.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {

  testWidgets('test render init  page', (tester) async {
    // expect(find.byType(), findsNWidgets(4));
    tester.pumpWidget(
        MaterialApp(
        home:  PassInitPage(),
    ));
  });
}