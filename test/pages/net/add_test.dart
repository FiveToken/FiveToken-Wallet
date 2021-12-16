

import 'package:fil/bloc/add/add_bloc.dart';
import 'package:fil/pages/net/add.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAddBloc extends Mock implements AddBloc{}

void main() {
  var bloc = MockAddBloc();
  NetAddPage();
  testWidgets('test render net list page', (tester) async {
    await tester.pumpWidget(
        Provider(
            create: (_) => bloc..add(AddListEvent())..add(DeleteListEvent()),
            child: MultiBlocProvider(
                providers: [BlocProvider<AddBloc>.value(value: bloc)],
                child: MaterialApp(
                  home: NetAddPage(),
                )
            )
        )
    );
    expect(find.text('add'.tr), findsOneWidget);
  });
}