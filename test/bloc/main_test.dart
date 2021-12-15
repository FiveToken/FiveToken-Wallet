import 'package:fil/bloc/connect/connect_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/common/global.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_test.mocks.dart';

@GenerateMocks([
  SharedPreferences
])
void main() {
  group('netBloc',(){
    MainBloc mainBloc;
    final filNet = Network.filecoinMainNet;
    final address = 'f17uqrg4ycvx6jrddzcpl7vwoptowp5wr2dzcw33a';
    final mockSharedPreferences = MockSharedPreferences();
    final network = Network.binanceTestnet;
    Global.store = mockSharedPreferences;
    setUp((){
      mainBloc = MainBloc();
    });

    when(Network.netList).thenReturn([]);
    when(OpenedBox.netInstance.values).thenReturn([]);
    when(Global.store.getBool('hideTestnet')).thenReturn(false);

    blocTest(
        'TestNetIsShowEvent',
        build: ()=> mainBloc,
        act: (bloc) => bloc.add(TestNetIsShowEvent(hideTestnet:false)),
        expect: ()=> [MainState(hideTestnet: false)]
    );

    blocTest(
        'GetBalanceEvent',
        build: ()=> mainBloc,
        act: (bloc) => bloc.add(GetBalanceEvent(filNet.rpc,filNet.chain,address)),
        expect: ()=> [false]
    );

    blocTest(
        'ResetBalanceEvent',
        build: ()=> mainBloc,
        act: (bloc) => bloc.add(ResetBalanceEvent()),
        expect: ()=> ['0']
    );


  });
}