import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  var text = WalletLabel;

  testWidgets("test render common card", (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CommonCard(Text(text)),
    ));
    expect(find.text(text), findsOneWidget);
  });
  testWidgets('test render tap card', (tester) async {
    var n = 0;
    await tester.pumpWidget(MaterialApp(
      home: TapCardWidget(
        Text(text),
        onTap: () {
          n++;
        },
      ),
    ));
    expect(n, 0);
    expect(find.text(text), findsOneWidget);
    await tester.tap(find.byType(Container));
    expect(n, 1);
  });
  testWidgets('test render tap item card', (tester) async {
    var n = 0, n2 = 0;
    var card1 = CardItem(
      label: WalletLabel,
      onTap: () {
        n++;
      },
    );
    var card2 = CardItem(
      label: WalletLabel,
      onTap: () {
        n2--;
      },
    );
    await tester.pumpWidget(MaterialApp(
      home: TapItemCard(
        items: [card1, card2],
      ),
    ));
    expect(find.byType(CardItem), findsNWidgets(2));
    await tester.tap(find.byWidget(card1));
    expect(n, 1);
    await tester.tap(find.byWidget(card2));
    expect(n2, -1);
  });
}
