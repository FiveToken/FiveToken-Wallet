import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain-new/global.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/walletConnect.dart';
import 'package:fil/init/hive.dart'; // OpenedBox
import 'package:fil/store/store.dart'; // $store

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.idle()) {
    on<HomeEvent>((event, emit) {});

    on<SetConnectedSessionEvent>((event, emit) {
      emit(state.copyWithHomeState(connectedSession: event.connectedSession));
    });

    on<SetMetaEvent>((event, emit) {
      emit(state.copyWithHomeState(meta: event.meta));
    });

    on<GetTokenListEvent>((event, emit) async {
      try {
        var tokenList = OpenedBox.tokenInstance.values
            .where((token) => token.rpc == $store.net.rpc)
            .toList();
        List<Token> list = [];
        if (tokenList.length > 0) {
          Chain.setRpcNetwork($store.net.rpc, $store.net.chain);
          final balances = await Future.wait([
            ...tokenList
                .map((e) => Chain.chainProvider
                    .getBalanceOfToken(event.mainAddress, e.address))
                .toList()
          ]);
          for (int i = 0; i < tokenList.length;i ++){
            final token = tokenList[i];
            final balance = balances[i];
            var item = {
              "symbol": token.symbol,
              "precision": token.precision,
              "address": token.address,
              "rpc": token.rpc,
              "chain": token.chain,
              "balance": balance
            };
            list.add(Token.fromJson(item));
            OpenedBox.tokenInstance.put(
                token.address + token.rpc,
                Token.fromJson(item)
            );
          }
          emit(state.copyWithHomeState(tokenList: list));
        }
      } catch (error) {
        print("================GetTokenListEvent2=========");
      }
    });
  }
}
