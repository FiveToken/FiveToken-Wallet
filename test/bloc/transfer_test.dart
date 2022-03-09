


import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/transfer/transfer_bloc.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/transaction_response.dart';
import 'package:fil/request/ether.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/credentials.dart';

import '../request/ether_test.mocks.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {
  setString(any, any2) {}
  getString(any){
    return 'binance';
  }
}


void main() {
  final mockStoreController = MockStoreController();

  group('TransferBloc',() {
    TransferBloc transferBloc;

    setUp(() {
      transferBloc = TransferBloc();
      var store = MockSharedPreferences();
      Global.store = store;
      var _address = '0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD';

      final web3Client = MockWeb3Client();
      final ether = Ether(Network.binanceTestnet.rpc,web3client: web3Client);
      when(
          ether.getNonce(_address )
      ).thenAnswer(
              (realInvocation) => Future.value(1)
      );



    });

    blocTest(
        'GetNonceEvent',
        build: ()=> transferBloc,
        act: (bloc) => transferBloc.add(GetNonceEvent(Network.binanceTestnet.rpc,'binance','0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD')),
        expect: ()=>  []
    );



  });
}