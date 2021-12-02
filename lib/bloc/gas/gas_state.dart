part of 'gas_bloc.dart';

class GasState extends Equatable {
  final String getGasState;
  final int timestamp;
  @override
  // TODO: implement props
  List<Object> get props => [this.getGasState];

  const GasState({ this.getGasState,this.timestamp});

  factory GasState.idle() {
    return GasState(getGasState: '',timestamp:0);
  }

  GasState copyWithGasState({
    String getGasState,
    int timestamp
  }){
    return GasState(
        getGasState: getGasState ??  this.getGasState,
        timestamp:timestamp ?? this.timestamp
    );
  }

}
