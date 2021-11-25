part of 'gas_bloc.dart';

class GasState extends Equatable {
  final String getGasState;
  @override
  // TODO: implement props
  List<Object> get props => [this.getGasState];

  const GasState({ this.getGasState});

  factory GasState.idle() {
    return GasState(getGasState: '');
  }

  GasState copyWithGasState({String getGasState}){
    return GasState(
        getGasState: getGasState ??  this.getGasState
    );
  }

}
