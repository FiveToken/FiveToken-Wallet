part of 'net_bloc.dart';

class NetEvent{
  const NetEvent();
}

class SetNetEvent extends NetEvent{
   final List<List<Network>> network;
   SetNetEvent(this.network);
}

