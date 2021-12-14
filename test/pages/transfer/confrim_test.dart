import 'package:fil/bloc/transfer/transfer_bloc.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/transfer/confirm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../widgets/dialog_test.dart';

class MockGasBloc extends Mock implements TransferBloc{}

void main() {
  var store = MockSharedPreferences();
  Global.store = store;
  Token token  = Token.fromJson({
     'symbol': 'FIL',
    'precision': 0,
    'address': 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
    'chain': 'eth',
    'rpc': 'https://api.fivetoken.io',
    'balance':'100000000000000'
  });
  Global.cacheToken = token;
  TransferBloc bloc = TransferBloc();
  String from = 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema';
  String rpc = 'https://api.fivetoken.io';
  String chainType = 'eth';
  testWidgets('test add transfer confirm page', (tester) async {
    await tester.pumpWidget(
        Provider(
            create: (_) => bloc..add(GetNonceEvent(rpc, chainType, from)),
            child: MultiBlocProvider(
                providers: [BlocProvider<TransferBloc>.value(value: bloc)],
                child: MaterialApp(
                  home:  TransferConfirmPage(),
                )
            )
        )
    );
  });

}
