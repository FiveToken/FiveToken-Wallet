import 'package:fil/bloc/price/price_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fil/chain/net.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('netBloc',(){
    PriceBloc priceBloc;

    final filNet = Network.filecoinMainNet;


    setUp((){
      priceBloc = PriceBloc();
    });

    blocTest(
        'ResetUsdPriceEvent',
        build: ()=> priceBloc,
        act: (bloc) => bloc.add(ResetUsdPriceEvent()),
        expect: ()=> [0]
    );

    blocTest(
        'GetPriceEvent',
        build: ()=> priceBloc,
        act: (bloc) => bloc.add(GetPriceEvent(filNet.chain)),
        expect: ()=> [
          '44'
        ]
    );


  });
}