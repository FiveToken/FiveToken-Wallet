import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';
part 'main_state.dart';
part 'main_event.dart';
class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.idle()) {
    on<AppOpenEvent>((event, emit) {
      // TODO: implement event handler
      // debugPrint("================AppOpenEvent=========" + event.count.toString());
    });
  }
}
