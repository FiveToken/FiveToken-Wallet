import 'package:fil/bloc/connect/connect_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_connect/models/wc_peer_meta.dart';
void main() {
  group('netBloc',(){
    ConnectBloc connectBloc;
    final fiveTokenMeta = WCPeerMeta(
      name: "FiveToken",
      url: "https://fivetoken.io/",
      description: "",
      icons: ['https://fivetoken.io/image/ft-logo.png'],
    );

    final peerMeta = WCPeerMeta(
      name:"Uniswap Interface",
      url:"https://app.uniswap.org",
      description:"Swap or provide liquidity on the Uniswap Protocol",
      icons:["https://app.uniswap.org/./favicon.png","https://app.uniswap.org/./images/192x192_App_Icon.png","https://app.uniswap.org/./images/512x512_App_Icon.png"]
    );

    setUp((){
      connectBloc = ConnectBloc();
    });

    blocTest(
        'SetConnectedSessionEvent',
        build: ()=> connectBloc,
        act: (bloc) => bloc.add(SetConnectedSessionEvent(connectedSession:peerMeta)),
        expect: ()=>  [ConnectState(connectedSession: peerMeta)]
    );

    blocTest(
        'SetMetaEvent',
        build: ()=> connectBloc,
        act: (bloc) => bloc.add(SetMetaEvent(meta:fiveTokenMeta)),
        expect: ()=>  [ConnectState(meta: fiveTokenMeta)]
    );

    blocTest(
        'ResetConnectEvent',
        build: ()=> connectBloc,
        act: (bloc) => bloc.add(ResetConnectEvent()),
        expect: ()=>  [ConnectState()]
    );
  });
}