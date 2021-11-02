import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
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
