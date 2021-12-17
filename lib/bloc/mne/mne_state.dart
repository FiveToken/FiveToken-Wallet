part of 'mne_bloc.dart';

class MneState extends Equatable {
  final int index;
  final bool showCode;

  const MneState({this.index, this.showCode});

  @override
  // TODO: implement props
  List<Object> get props => [index, showCode];

  factory MneState.idle() {
    return MneState(index: 0, showCode: false);
  }

  MneState copy({int index,  bool showCode}){
    return MneState(
        index: index ?? this.index,
        showCode: showCode ??  this.showCode
    );
  }

}
