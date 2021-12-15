

import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/address/net.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../box.dart';
import '../../widgets/dialog_test.dart';
class MockMainBloc extends Mock implements MainBloc{}

void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  MainBloc bloc = MockMainBloc();
  OpenedBox.netInstance = mockNetbox();
  when(OpenedBox.netInstance.values).thenReturn([]);
  testWidgets('address net', (tester) async {
    await tester.pumpWidget(
        Provider(
          create: (_) => bloc.add(TestNetIsShowEvent(hideTestnet: true)),
          child: MultiBlocProvider(
              providers: [BlocProvider<MainBloc>.value(value: bloc)],
              child: MaterialApp(
                home:  AddressBookNetPage(),
              )
          )
      )
    );
    expect(find.text('selectAddrNet'.tr), findsOneWidget);
  });
}