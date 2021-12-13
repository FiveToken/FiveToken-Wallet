import 'package:fil/pages/transfer/detail.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  testWidgets('test add token page', (tester) async {
    Get.toNamed(filDetailPage, arguments: {'type': 1});
    await tester.pumpWidget(
        GetMaterialApp(
            home: FilDetailPage()
        )
    );
  });
}
