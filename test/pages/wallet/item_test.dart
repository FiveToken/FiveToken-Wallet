import 'package:fil/index.dart';
import 'package:fil/pages/wallet/widgets/messageItem.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../constant.dart';

void main() {
  Get.put(StoreController());
  testWidgets("test message item", (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MessageItem(CacheMessage(
          blockTime: getSecondSinceEpoch(),
          hash: '',
          pending: 0,
          from: EthAddr,
          to: EthAddr)),
    ));
    expect(find.byType(IconBtn), findsOneWidget);
  });
}
