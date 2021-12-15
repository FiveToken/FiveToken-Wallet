import 'package:fil/bloc/net/net_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fil/init/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/chain/net.dart';
import 'package:mockito/mockito.dart';
import '../box.dart';
void main() {
  group('netBloc',(){
    OpenedBox.netInstance = MockBox<Network>();
    when(OpenedBox.netInstance.values).thenReturn([]);
    print(OpenedBox.netInstance.values);
    NetBloc netBloc = NetBloc();
    List<List<Network>> net = Network.netList;
    blocTest(
      'emit when',
      build: ()=> netBloc,
      act: (bloc) => bloc.add(SetNetEvent(net)),
      expect: ()=> [NetState(network: net)]
    );
  });
}