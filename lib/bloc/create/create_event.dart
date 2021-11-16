part of 'create_bloc.dart';

class CreateEvent {
  const CreateEvent();
}

class SetCreateEvent extends CreateEvent{
  final String mne;
  final List<String> unSelectedList;
  final List<String> selectedList;
  SetCreateEvent({this.mne, this.unSelectedList, this.selectedList});
}

class UpdateEvent extends CreateEvent{
  final int type;
  UpdateEvent({this.type});
}

class DeleteEvent extends CreateEvent{
  final int type;
  DeleteEvent({this.type});
}