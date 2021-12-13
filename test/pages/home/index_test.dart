import 'package:fil/pages/home/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main page test', (tester) async {
    await tester.pumpWidget(
      MainPage(),
    );

    // expect(find.byType(QrImage), findsOneWidget);
    // QrImage qr = tester.widget(find.byType(QrImage));
    // expect(qr.size, 188.0);
  });
}