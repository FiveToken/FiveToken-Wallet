// import 'package:equatable/equatable.dart';
part of 'price_bloc.dart';
class PriceState extends Equatable {
  final double usdPrice;
  PriceState({
     this.usdPrice
  });
  factory PriceState.idle() {
    return PriceState(
        usdPrice: 0
    );
  }

  PriceState copy({double usdPrice}){
    return PriceState(
        usdPrice: usdPrice??this.usdPrice
    );
  }


  @override
  // TODO: implement props
  List<Object> get props => [this.usdPrice];

}
