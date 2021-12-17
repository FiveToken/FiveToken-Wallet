import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'mne_event.dart';
part 'mne_state.dart';

class MneBloc extends Bloc<MneEvent, MneState> {
  MneBloc() : super(MneState.idle()) {
    on<MneEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<SetMneEvent>((event, emit){
      emit(state.copy(index: event.index, showCode: event.showCode));
    });
  }
}
