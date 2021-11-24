import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/address.dart';
import 'package:meta/meta.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(AddressState.idle()) {
    on<AddressListEvent>((event, emit){
      var box = OpenedBox.get<ContactAddress>();
       final list = box.values.where((addr) => addr.rpc == event.network.rpc).toList();
      emit(state.copy(list,event.network));
    });
    on<DeleteListEvent>((event, emit){
      var box = OpenedBox.get<ContactAddress>();
      box.delete(event.addr.key);
      List<ContactAddress> tmpList = state.list.map((e) => e).toList();
      tmpList.removeAt(event.index);
      emit(state.setList(tmpList));
    });
    on<NetworkEvent>((event, emit){
       emit(state.setNetwork(event.network));
    });
  }
}
