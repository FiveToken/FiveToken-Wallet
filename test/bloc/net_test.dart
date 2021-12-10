import 'package:fil/bloc/net/net_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/chain/net.dart';
void main() {
  List<List<Network>> net = Network.netList;
  group('netBloc',(){
     NetBloc netBloc;

    setUp((){
      netBloc = NetBloc();
    });

    blocTest(
      'emit when',
      build: ()=> netBloc,
      act: (bloc) => bloc.add(SetNetEvent(net)),
      expect: ()=> [net]
    );
  });
}