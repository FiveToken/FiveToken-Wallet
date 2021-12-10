import 'package:fil/index.dart';
import 'package:fil/widgets/fresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  testWidgets('test refresh widget', (tester) async {
    var n = 0;
    await tester.pumpWidget(MaterialApp(
      home: CustomRefreshWidget(
        onRefresh: () async {
          n++;
        },
        child: ListView.builder(
          itemBuilder: (c, i) => Center(
            child: Text(WalletLabel),
          ),
          itemCount: 20,
          itemExtent: 100,
        ),
      ),
    ));
    await tester.drag(find.byType(CustomRefreshWidget), Offset(0, 100));
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(n, 1);
  });
}
