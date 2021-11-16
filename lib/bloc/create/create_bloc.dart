import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/index.dart';
import 'package:meta/meta.dart';

part 'create_event.dart';
part 'create_state.dart';

class CreateBloc extends Bloc<CreateEvent, CreateState> {
  CreateBloc() : super(CreateState.idle()) {
    on<CreateEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<SetCreateEvent>((event, emit){
      emit(state.copy(event.mne, event.unSelectedList, event.selectedList));
    });
    on<UpdateEvent>((event, emit){
      List<String> select = state.selectedList.map((e) => e).toList();
      List<String> unselect = state.unSelectedList.map((e) => e).toList();
      var rm = unselect.removeAt(event.type);
      select.add(rm);
      emit(state.copyType(event.type, unselect, select));
    });
    on<DeleteEvent>((event, emit){
      List<String> select = state.selectedList.map((e) => e).toList();
      List<String> unselect = state.unSelectedList.map((e) => e).toList();
      var rm = select.removeAt(event.type);
      unselect.add(rm);
      emit(state.copyType(event.type, unselect, select));
    });
  }
}
