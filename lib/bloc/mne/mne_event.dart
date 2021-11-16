part of 'mne_bloc.dart';

class MneEvent {
  const MneEvent();
}

class SetMneEvent extends MneEvent{
  final int index ;
  final bool showCode;
  SetMneEvent({this.index, this.showCode});
}
