import 'package:fil/bloc/home/home_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/home/widgets/token.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/random.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mockito/mockito.dart';
import 'package:web3dart/web3dart.dart';

import '../../../box.dart';
import '../../../constant.dart';
import 'package:provider/provider.dart';
class MockWeb3Client extends Mock implements Web3Client {}

class MockHomeBloc extends Mock implements HomeBloc{}
void main() {
  Get.put(StoreController());
  var client = MockWeb3Client();
  OpenedBox.tokenInstance = mockTokenBox();
  var net = Network.ethMainNet;
  HomeBloc bloc = MockHomeBloc();
  $store.setNet(net);
  $store.setWallet(ChainWallet(
      address: EthAddr, rpc: net.rpc, label: WalletLabel, balance: '1000'));
  when(OpenedBox.tokenInstance.values).thenReturn([Token(rpc: net.rpc, address: EthAddr)]);
  when(OpenedBox.tokenInstance.put(any, any)).thenAnswer((realInvocation) => null);
  when(client.call(
          contract: anyNamed('contract'),
          function: anyNamed('function'),
          params: anyNamed('params')))
      .thenAnswer((realInvocation) async => ['100']);
  // testWidgets('test render token widget', (tester) async {
  //   await tester.pumpWidget(
  //       Provider(
  //           create: (_) => bloc,
  //           child: MultiBlocProvider(
  //               providers: [BlocProvider<HomeBloc>.value(value: bloc)],
  //               child: MaterialApp(
  //                 home:  TokenList(),
  //               )
  //           )
  //       )
  //   );
  //   // await tester.pumpAndSettle(Duration(seconds: 3));
  //   // expect(find.byType(RandomIcon), findsOneWidget);
  // });
  testWidgets('test main token widget', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MainTokenWidget(),
    ));
    // print($store.wal.formatBalance);
    // expect(find.text('1000 wei'), findsOneWidget);
  });
}
