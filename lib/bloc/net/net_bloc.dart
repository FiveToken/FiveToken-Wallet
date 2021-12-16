import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/init/hive.dart';
import 'package:meta/meta.dart';
import 'package:fil/chain/net.dart';

part 'net_event.dart';
part 'net_state.dart';

class NetBloc extends Bloc<NetEvent, NetState> {
  NetBloc() : super(NetState.idle()) {
    on<SetNetEvent>((event, emit){
      print(event);
      emit(state.copy(event.network));
    });
  }
}
