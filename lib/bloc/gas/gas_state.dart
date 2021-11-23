part of 'gas_bloc.dart';

class GasState extends Equatable {
  final ChainGas gas;
  @override
  // TODO: implement props
  List<Object> get props => [this.gas];

  const GasState({ this.gas});

  factory GasState.idle() {
    return GasState(gas: ChainGas());
  }

  GasState copyWithGasState({ChainGas gas}){
    return GasState(
      gas: gas ??  this.gas
    );
  }

}
