import 'package:fil/index.dart';
import 'package:fil/pages/wallet/qr_code.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  Get.put(StoreController());
  testWidgets('test render qrcode', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: WalletCodePage(),
    ));
    expect(find.byType(QrImage), findsOneWidget);
    QrImage qr = tester.widget(find.byType(QrImage));
    expect(qr.size, 188.0);
  });
}
