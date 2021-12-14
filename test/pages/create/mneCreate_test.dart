import 'package:fil/pages/create/mneCreate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

void main() {
  testWidgets('test render mne create page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MneCreatePage(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(MneItem), findsNWidgets(12));
    expect(find.text('know'.tr), findsOneWidget);
  });
}
