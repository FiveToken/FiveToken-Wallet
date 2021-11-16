part of 'gas_bloc.dart';

class GasState extends Equatable {
  final int index;
  final ChainGas chainGas;
  @override
  // TODO: implement props
  List<Object> get props => [index, chainGas];

  const GasState({this.index, this.chainGas});

  factory GasState.idle() {
    return GasState(index: 0, chainGas: ChainGas());
  }



  GasState copy({int index, ChainGas chainGas}){
    return GasState(
      index: index ?? this.index,
      chainGas: chainGas ??  this.chainGas
    );
  }

}
