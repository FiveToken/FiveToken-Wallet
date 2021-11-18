part of 'address_bloc.dart';

class AddressEvent {
  const AddressEvent();
}

class AddressListEvent extends AddressEvent {
  final List<ContactAddress> list;
  final Network network;
  AddressListEvent({this.list,this.network});
}

class DeleteListEvent extends AddressEvent{
  final ContactAddress addr;
  final int index;
  DeleteListEvent({this.addr, this.index});
}

class NetworkEvent extends AddressEvent{
  final Network network;
  NetworkEvent(this.network);
}