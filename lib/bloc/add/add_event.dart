part of 'add_bloc.dart';

class AddEvent {
  const AddEvent();
}

class SetAddEvent extends AddEvent{
  final List<List<Network>> network;
  SetAddEvent(this.network);
}

class AddListEvent extends AddEvent{
  final String rpc;
  final Network network;
  AddListEvent({this.rpc, this.network});
}

class DeleteListEvent extends AddEvent {
  final String rpc;
  DeleteListEvent({this.rpc});
}


