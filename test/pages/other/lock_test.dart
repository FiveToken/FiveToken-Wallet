import 'package:fil/bloc/lock/lock_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/pages/other/lock.dart';
import 'package:fil/pages/other/set.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../../widgets/dialog_test.dart';

class MockLockBloc extends Mock implements LockBloc{}

void main() {
  LockBloc bloc = MockLockBloc();
  testWidgets('test render other lock', (tester) async {
    await tester.runAsync(() async {
      var store = MockSharedPreferences();
      Global.store = store;
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: setPage,
        getPages: [
          GetPage(name: lockPage, page: () =>
              Provider(
                  create: (_) => bloc,
                  child: MultiBlocProvider(
                      providers: [BlocProvider<LockBloc>.value(value: bloc)],
                      child: MaterialApp(
                      home:  LockPage(),
                   )
                  )
              )
          ),
          GetPage(page: () => SetPage(), name: setPage),
        ],
      ));
      expect(find.byType(TapItemCard), findsNWidgets(3));
      await tester.tap(find.text('lockScreenSetting'.tr));
      expect(Get.currentRoute, lockPage);
    });
  });
}