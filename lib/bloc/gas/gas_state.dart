part of 'gas_bloc.dart';

class GasState extends Equatable {
  final ChainGas chainGas;
  @override
  // TODO: implement props
  List<Object> get props => [this.chainGas];

  const GasState({ this.chainGas});

  factory GasState.idle() {
    return GasState(chainGas: ChainGas());
  }

  GasState copyWithGasState({String handlingFee, ChainGas chainGas}){
    return GasState(
      chainGas: chainGas ??  this.chainGas
    );
  }

}
