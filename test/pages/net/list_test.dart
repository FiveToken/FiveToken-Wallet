import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/net/net_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/pages/net/list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mockito/mockito.dart';
import '../../box.dart';
import 'package:provider/provider.dart';

class MockNetBloc extends Mock implements NetBloc{}

void main() {
  NetBloc bloc = MockNetBloc();

  var box = mockNetbox();
  when(box.values).thenReturn([]);
  testWidgets('test render net list page', (tester) async {
    // await tester.pumpWidget(GetMaterialApp(home: NetIndexPage()));
    await tester.pumpWidget(
      Provider(
        create: (_) => bloc..add(SetNetEvent(Network.netList)),
        child: MultiBlocProvider(
             providers: [BlocProvider<NetBloc>.value(value: bloc)],
            child: MaterialApp(
              home: NetIndexPage(),
            )
        )
      )
    );
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(Network.supportNets.length));
  });
}
