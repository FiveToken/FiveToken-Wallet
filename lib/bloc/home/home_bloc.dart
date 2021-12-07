import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/init/hive.dart'; // OpenedBox
import 'package:fil/request/global.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.idle()) {
    on<HomeEvent>((event, emit) {});

    on<GetTokenListEvent>((event, emit) async {
      try {
        var tokenList = OpenedBox.tokenInstance.values
            .where((token) => token.rpc == event.rpc)
            .toList();
        List<Token> list = [];
        if (tokenList.length > 0) {
          Chain.setRpcNetwork(event.rpc, event.chainType);
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
          emit(state.copyWithHomeState(tokenList: list,chainType:event.chainType));
        }else{
          emit(state.copyWithHomeState(tokenList: list,chainType:event.chainType));
        }
      } catch (error) {
        print("================GetTokenListEvent2=========");
      }
    });
  }
}
