part of 'gas_bloc.dart';

@immutable
abstract class GasEvent {}

class ChangeIndex extends GasEvent {
  final int index ;
  final ChainGas chainGas;
  ChangeIndex({this.index, this.chainGas});
}