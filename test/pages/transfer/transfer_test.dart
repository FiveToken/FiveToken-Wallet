import 'package:fil/bloc/gas/gas_bloc.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/index.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/common/global.dart';
import 'package:fil/pages/transfer/transfer.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../widgets/dialog_test.dart';

class MockGasBloc extends Mock implements GasBloc{}

void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  GasBloc bloc = MockGasBloc();
  Network net = Network.ethMainNet;
  ChainWallet wal = ChainWallet(
    label: 'DD',
    address: '0x3fb4f280cf531ba7d88fe4d0748a451e4d4276ad',
    type: 2,
    balance: '400000000000000',
    mne: '',
    addressType: 'eth',
    skKek: 'CGmTwXja66YS39Y3Lp5MmUWNRMx5mp8YBstteIJDpHjK9vTyoDfbahaRY6+/RF4NfhKqyzmWckA1ngd3CG+FDWzkKNeoqW9BiY4cA89D+x8=',
    digest: 'r57NXYt4/wElj612To5Rkg==',
    groupHash: '',
    rpc: 'https://mainnet.infura.io/v3/'
  );
  $store.setNet(net);
  $store.setWallet(wal);
  String title= 'transfer';
  testWidgets('test transfer transfer', (tester) async {
    await tester.pumpWidget(
        Provider(
            create: (_) => bloc..add(UpdateMessListStateEvent($store.net.rpc, $store.net.chain, title)),
            child: MultiBlocProvider(
                providers: [BlocProvider<GasBloc>.value(value: bloc)],
                child: MaterialApp(
                  home:  FilTransferNewPage(),
                )
            )
        )
    );
    print(Get.currentRoute);
    // await tester.tap(find.text('next'.tr));
    // expect(find.text('next'.tr), true);
  });
}