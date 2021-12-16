import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/bloc/transfer/transfer_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/global.dart';
import 'package:fil/pages/transfer/confirm.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../widgets/dialog_test.dart';

class MockGasBloc extends Mock implements TransferBloc{}

class MockMainBloc extends Mock implements MainBloc{}

void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  Token token  = Token.fromJson({
     'symbol': 'FIL',
    'precision': 0,
    'address': 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
    'chain': 'eth',
    'rpc': 'https://api.fivetoken.io',
    'balance':'100000000000000'
  });
  Global.cacheToken = token;
  TransferBloc bloc = TransferBloc();
  MainBloc mainbloc = MainBloc();
  Network net = Network.ethMainNet;
  $store.setNet(net);
  String from = 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema';
  String rpc = 'https://api.fivetoken.io';
  String chainType = 'eth';
  testWidgets('test add transfer confirm page', (tester) async {
    await tester.pumpWidget(
        Provider(
            create: (_) => bloc..add(GetNonceEvent(rpc, chainType, from)),
            child: MultiBlocProvider(
                providers: [BlocProvider<TransferBloc>.value(value: bloc), BlocProvider<MainBloc>.value(value:mainbloc)],
                child: MaterialApp(
                  home:  TransferConfirmPage(),
                )
            )
        )
    );
  });

}
