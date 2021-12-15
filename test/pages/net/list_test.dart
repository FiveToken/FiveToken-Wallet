import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/net/net_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/net/add.dart';
import 'package:fil/pages/net/list.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import '../../box.dart';
import 'package:provider/provider.dart';

class MockNetBloc extends Mock implements NetBloc{}

void main() {
  NetBloc bloc = MockNetBloc();
  var box = mockNetbox();
  when(box.values).thenReturn([]);
  OpenedBox.netInstance = MockBox<Network>();
  when(OpenedBox.netInstance.values).thenReturn([]);
  print(OpenedBox.netInstance.values);
  testWidgets('test render net list page', (tester) async {
    // await tester.pumpWidget(GetMaterialApp(home: NetIndexPage()));
    await tester.pumpWidget(
      Provider(
        create: (_) => bloc.add(SetNetEvent(Network.netList)),
        child: MultiBlocProvider(
             providers: [BlocProvider<NetBloc>.value(value: bloc)],
            child: GetMaterialApp(
              initialRoute: netIndexPage,
              getPages: [
                GetPage(name: netIndexPage, page: () => NetIndexPage()),
                GetPage(name: netAddPage, page: () => NetAddPage())
              ],
            )
        )
      )
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
    print(find.text('add'.tr));
    await tester.tap(find.text('add'.tr));
    await tester.pumpAndSettle();

    Get.toNamed(netIndexPage);
    await tester.pumpAndSettle();

  });
}
