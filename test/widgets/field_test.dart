import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  testWidgets('test field widget without label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Field(),
      ),
    ));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(CommonText), findsNothing);
  });
  testWidgets('test field widget with label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Field(
          label: WalletLabel,
        ),
      ),
    ));
    expect(find.byType(CommonText), findsOneWidget);
  });
  testWidgets('test field widget with extra', (tester) async {
    var text = WalletLabel;
    var extra = Text(text);
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Field(
          extra: extra,
        ),
      ),
    ));
    expect(find.text(text), findsOneWidget);
  });
  testWidgets('test enter text', (tester) async {
    var text = WalletLabel;
    TextEditingController controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Field(
          controller: controller,
        ),
      ),
    ));
    await tester.enterText(find.byType(TextField), text);
    expect(controller.text, text);
  });
}
