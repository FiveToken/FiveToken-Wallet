import 'package:fil/common/utils.dart';
import 'package:fil/index.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/pages/wallet/main.dart';
import 'package:fil/pages/wallet/widgets/messageItem.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

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
