import 'package:fil/chain/wallet.dart';
import 'package:fil/common/global.dart';
import 'package:fil/index.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {
  getBool(any) {}

  setString(any, any2) {}
}

void main() {
  testWidgets("test delete dialog", (tester) async {
    var title = 'Delete';
    var content = 'Confirm to delete';
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Builder(
          builder: (BuildContext context) {
            return TextButton(
                onPressed: () {
                  showDeleteDialog(context, title: title, content: content);
                },
                child: Text('click'));
          },
        ),
      ),
    ));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);
    expect(find.text(content), findsOneWidget);
  });
  testWidgets("test pass dialog", (tester) async {
    var store = MockSharedPreferences();
    Global.store = store;
    when(store.getInt(any)).thenReturn(0);

    var pass = '';
    var wallet = ChainWallet(
        label: WalletLabel,
        address: FilAddr,
        type: 0,
        balance: '0',
        mne:
            'sMKr+5Nte5wqM1WIWvcgg/rPBI5WzlWlK1Q8Ij4iuM4Buf9xHAClhqlWd6KwdWVWbtYa5E951cRhdLe3cvzBIMVDWBcfdlHQeHaa3vE0gnc=',
        skKek: 'Z5tz8fHqUqGNMHb47KCzPaAq0tKMgxEAcCOk5ri6ysE=',
        digest: 'yCjEF6kR8IgjHm/xz4GLpA==',
        groupHash: '');
    await tester.pumpWidget(GetMaterialApp(
      home: Material(
        child: Builder(
          builder: (BuildContext context) {
            return TextButton(
                onPressed: () {
                  showPassDialog(context, (p) {
                    pass = p;
                  }, wallet: wallet);
                },
                child: Text('click'));
          },
        ),
      ),
    ));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(find.text('sure'), findsOneWidget);
    await tester.enterText(find.byType(TextField), WalletLabel);
    await tester.tap(find.text('sure'));
    await tester.pumpAndSettle();
    expect(pass, WalletLabel);
  });
}
