
import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/home/home_bloc.dart';
import 'package:fil/init/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../box.dart';


void main() {
  group('homeBloc',(){
    HomeBloc homeBloc;
    String rpc = 'https://mainnet.infura.io/v3/';
    setUp((){
      homeBloc = HomeBloc();
      OpenedBox.tokenInstance = mockTokenBox();
      when(OpenedBox.tokenInstance.values).thenReturn([]);
    });

    blocTest(
        'SetConnectedSessionEvent',
        build: ()=> homeBloc,
        act: (bloc) => bloc.add(GetTokenListEvent(rpc,'eth','0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD')),
        expect: ()=>  [HomeState(tokenList: [],chainType:'eth')]
    );
  });
}