import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  testWidgets('test render scaffold', (tester) async {
    var title = WalletLabel;
    await tester.pumpWidget(MaterialApp(
      home: CommonScaffold(
        title: title,
      ),
    ));
    expect(find.text(title), findsOneWidget);
    expect(find.byType(FlatButton), findsOneWidget);
  });
  testWidgets('test press footer button', (tester) async {
    var title = WalletLabel;
    var n = 0;
    await tester.pumpWidget(MaterialApp(
      home: CommonScaffold(
        title: title,
        onPressed: () {
          n++;
        },
      ),
    ));
    await tester.tap(find.byType(FlatButton));
    expect(n, 1);
  });
}
