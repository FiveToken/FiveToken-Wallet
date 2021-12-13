import 'package:fil/bloc/home/home_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/init/hive.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('netBloc',() async {
    HomeBloc homeBloc;

    setUp((){
      homeBloc = HomeBloc();
    });

    final filNet = Network.filecoinMainNet;
    final address = '0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD';
    final rpc = 'https://data-seed-prebsc-1-s2.binance.org:8545';

    OpenedBox.tokenInstance.put(
        address + rpc,
        Token(
            symbol: 'TODO',
            precision: 9,
            address: '0x9343bc852c04690b239ec733c6f71d8816d436c3',
            rpc: rpc,
            chain: 'binance'
        )
    );
    List list = [];
    var item = {
      "symbol": "TODO",
      "precision": 9,
      "address": "0x9343bc852c04690b239ec733c6f71d8816d436c3",
      "rpc": rpc,
      "chain": 'binance',
      "balance": '0'
    };
    list.add(Token.fromJson(item));

    blocTest(
        'GetTokenListEvent',
        build: ()=> homeBloc,
        act: (bloc) => bloc.add(GetTokenListEvent(filNet.rpc,filNet.chain,address)),
        expect: ()=> [list,'binance']
    );

  });
}