import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

void main() {
  Get.put(StoreController());
  testWidgets('test other scan', (tester) async {
    await tester.pumpWidget(
        GetMaterialApp(
            initialRoute: scanPage,
            getPages: [
              GetPage(name: scanPage, page: () => ScanPage())
            ]
        )
    );
  });
}