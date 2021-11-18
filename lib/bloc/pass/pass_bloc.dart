import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'pass_event.dart';
part 'pass_state.dart';

class PassBloc extends Bloc<PassEvent, PassState> {
  PassBloc() : super(PassState.idle()) {
    on<SetPassEvent>((event, emit) {
       emit(state.copy(passShow: event.passShow));
    });
  }
}
