import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/net/list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';

void main() {
  var box = mockNetbox();
  when(box.values).thenReturn([]);
  testWidgets('test render net list page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(home: NetIndexPage()));
    expect(find.byIcon(Icons.lock_outline),
        findsNWidgets(Network.supportNets.length));
  });
}
