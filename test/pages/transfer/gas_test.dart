import 'package:fil/bloc/gas/gas_bloc.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/pages/transfer/gas.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockGasBloc extends Mock implements GasBloc{}

void main() {
  Get.put(StoreController());
  var gas = ChainGas();
  $store.setGas(gas);
  GasBloc bloc = MockGasBloc();
  
  testWidgets('test transfer gas', (tester) async {
    await tester.pumpWidget(
        Provider(
            create: (_) => bloc,
            child: MultiBlocProvider(
                providers: [BlocProvider<GasBloc>.value(value: bloc)],
                child: MaterialApp(
                  home:  ChainGasPage(),
                )
            )
        )
    );
    expect(find.text('sure'.tr), findsOneWidget);
  });
}