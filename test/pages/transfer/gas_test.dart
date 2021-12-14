import 'package:fil/bloc/gas/gas_bloc.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/transfer/gas.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockGasBloc extends Mock implements GasBloc{}

void main() {
  
  GasBloc bloc = MockGasBloc();
  
  testWidgets('test transfer gas', (tester) async {
    await tester.pumpWidget(
        Provider(
            create: (_) => bloc,
            child: MultiBlocProvider(
                providers: [BlocProvider<GasBloc>.value(value: bloc)],
                child: MaterialApp(
                  home:  ChainGasPage(),
                )
            )
        )
    );
    expect(find.text('sure'.tr), true);
  });
}