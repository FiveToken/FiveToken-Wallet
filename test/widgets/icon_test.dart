import 'package:fil/widgets/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test coin icon widget', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Column(
        children: CoinIcon.icons.values
            .toList()
            .map((coin) => Container(
                  color: coin.bg,
                  child: coin.icon,
                ))
            .toList(),
      ),
    ));
    expect(find.byType(Image), findsNWidgets(CoinIcon.icons.values.length));
  });
}
