import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/init/hive.dart';
import 'package:meta/meta.dart';

part 'add_event.dart';
part 'add_state.dart';

class AddBloc extends Bloc<AddEvent, AddState> {
  AddBloc() : super(AddState()) {
    on<AddEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<AddListEvent>((event, emit){
      var box = OpenedBox.netInstance;
      box.put(event.rpc, event.network);
    });
    on<DeleteListEvent>((event, emit){
      var box = OpenedBox.netInstance;
      box.delete({event.rpc});
    });
  }
}
