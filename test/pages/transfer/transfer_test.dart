import 'package:fil/pages/transfer/transfer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  testWidgets('test add token page', (tester) async {
    await tester.pumpWidget(
        GetMaterialApp(
            home: FilTransferNewPage()
        )
    );
  });
}
