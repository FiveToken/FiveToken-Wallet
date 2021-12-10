import 'package:fil/index.dart';
import 'package:fil/pages/net/token.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web3dart/web3dart.dart';

import '../../constant.dart';

class MockWeb3Client extends Mock implements Web3Client {}

void main() {
  Get.put(StoreController());
  var client = MockWeb3Client();
  testWidgets('test add token page', (tester) async {
    when(client.call(
            contract: anyNamed('contract'),
            function: anyNamed('function'),
            params: anyNamed('params')))
        .thenAnswer((realInvocation) async => ['18']);
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
            home: TokenAddPage())));

    await tester.enterText(find.byType(TextField).first, EthAddr);
    TokenAddPageState state =
        tester.state<TokenAddPageState>(find.byType(TokenAddPage));
    state.getMetaInfo(EthAddr);
    await tester.pumpAndSettle(Duration(seconds: 3));
    expect(state.preCtrl.text, '18');
    expect(state.symbolCtrl.text, '18');
  });
}
