import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/gas.dart';
import 'package:meta/meta.dart';

part 'gas_event.dart';
part 'gas_state.dart';

class GasBloc extends Bloc<GasEvent, GasState> {
  GasBloc() : super(GasState.idle()) {
    on<ChangeIndex>((event, emit) {
      final res = state.copy(index: event.index, chainGas: event.chainGas);
      emit(res);
    });
  }
}
