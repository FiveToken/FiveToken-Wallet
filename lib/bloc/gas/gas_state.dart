part of 'gas_bloc.dart';

class GasState extends Equatable {
  final String getGasState;
  final String errorMessage;
  final int timestamp;
  @override
  // TODO: implement props
  List<Object> get props => [this.getGasState,this.errorMessage];

  const GasState({ this.getGasState,this.timestamp,this.errorMessage});

  factory GasState.idle() {
    return GasState(getGasState: '',errorMessage:"",timestamp:0);
  }

  GasState copyWithGasState({
    String getGasState,
    String errorMessage,
    int timestamp
  }){
    return GasState(
        getGasState: getGasState ??  this.getGasState,
        errorMessage: errorMessage ?? this.errorMessage,
        timestamp:timestamp ?? this.timestamp
    );
  }

}
