// import 'package:equatable/equatable.dart';
part of 'price_bloc.dart';
class PriceState extends Equatable {
  String priceMarket;
  PriceState({
     this.priceMarket
  });
  factory PriceState.idle() {
    return PriceState(
        priceMarket: ''
    );
  }

  PriceState copy({String priceMarket}){
    return PriceState(
      priceMarket: priceMarket??this.priceMarket
    );
  }


  @override
  // TODO: implement props
  List<Object> get props => [this.priceMarket];

}
