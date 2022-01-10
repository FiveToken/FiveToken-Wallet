part of 'gas_bloc.dart';

class GasState extends Equatable {
  final String getGasState;
  final String errorMessage;
  final int timestamp;
  final String tab;
  final String gear;
  final String handlingFee;

  @override
  // TODO: implement props
  List<Object> get props => [
    this.getGasState,
    this.errorMessage,
    this.tab,
    this.gear,
    this.handlingFee
  ];

  const GasState({
    this.getGasState,
    this.timestamp,
    this.errorMessage,
    this.tab,
    this.gear,
    this.handlingFee
  });

  factory GasState.idle() {
    return GasState(
        getGasState: '',
        errorMessage:"",
        timestamp:0,
        tab:'',
        gear:'',
        handlingFee:'0'
    );
  }

  GasState copyWithGasState({
    String getGasState,
    String errorMessage,
    int timestamp,
    String tab,
    String gear,
    String handlingFee
  }){
    return GasState(
        getGasState: getGasState ??  this.getGasState,
        errorMessage: errorMessage ?? this.errorMessage,
        timestamp:timestamp ?? this.timestamp,
        tab:tab ?? this.tab,
        gear:gear ?? this.gear,
        handlingFee:handlingFee??this.handlingFee
    );
  }

}
