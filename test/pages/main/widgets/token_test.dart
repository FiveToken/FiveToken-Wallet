import 'package:fil/index.dart';
import 'package:fil/pages/main/widgets/token.dart';
import 'package:fil/widgets/random.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:web3dart/web3dart.dart';

import '../../../box.dart';
import '../../../constant.dart';

class MockWeb3Client extends Mock implements Web3Client {}

void main() {
  Get.put(StoreController());
  var client = MockWeb3Client();
  var box = mockTokenBox();
  var net = Network.ethMainNet;
  $store.setNet(net);
  $store.setWallet(ChainWallet(
      address: EthAddr, rpc: net.rpc, label: WalletLabel, balance: '1000'));
  when(box.values).thenReturn([Token(rpc: net.rpc, address: EthAddr)]);
  when(box.put(any, any)).thenAnswer((realInvocation) => null);
  when(client.call(
          contract: anyNamed('contract'),
          function: anyNamed('function'),
          params: anyNamed('params')))
      .thenAnswer((realInvocation) async => ['100']);
  testWidgets('test render token widget', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TokenList(),
    ));
    await tester.pumpAndSettle(Duration(seconds: 3));
    expect(find.byType(RandomIcon), findsOneWidget);
  });
  testWidgets('test main token widget', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MainTokenWidget(),
    ));
    print($store.wal.formatBalance);
    expect(find.text('1000 wei'), findsOneWidget);
  });
}
